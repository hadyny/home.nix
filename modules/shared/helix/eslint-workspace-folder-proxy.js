// A stdio proxy that tells the ESLint language server where the project root is.
//
// The server asks the client for its settings with `workspace/configuration`,
// and it reads `workspaceFolder` from the reply. Helix replies with a fixed
// configuration and ignores the `scopeUri` of each item. See
// `MethodCall::WorkspaceConfiguration` in helix-term/src/application.rs. The
// field therefore never arrives.
//
// Without that field the server uses `path.dirname(file)` as the ESLint working
// directory, for `auto` mode and for `location` mode both. A relative path in
// the ESLint configuration, such as `./tsconfig.eslint.json`, then resolves
// beside the open file and the lint fails.
//
// This proxy adds the field. Helix starts each server in the workspace root,
// because helix-lsp/src/client.rs calls `.current_dir(&root_path)`, so the
// working directory of this process is the correct project root.
//
// Usage: node eslint-workspace-folder-proxy.js <server> [args...]

"use strict";

const { spawn } = require("node:child_process");
const path = require("node:path");
const { pathToFileURL } = require("node:url");

const [serverPath, ...serverArgs] = process.argv.slice(2);
if (!serverPath) {
	process.stderr.write("eslint proxy: no server path\n");
	process.exit(2);
}

const root = process.cwd();
const workspaceFolder = {
	uri: pathToFileURL(root).href,
	name: path.basename(root) || root,
};

const server = spawn(serverPath, serverArgs, {
	stdio: ["pipe", "pipe", "inherit"],
});

// The identifiers of the `workspace/configuration` requests that the server
// sent and that have no reply yet.
const pending = new Set();

// Read Language Server Protocol messages from a byte stream. `onMessage`
// receives the parsed message and the unchanged bytes of the full message.
function createParser(onMessage) {
	let buffer = Buffer.alloc(0);
	return (chunk) => {
		buffer = Buffer.concat([buffer, chunk]);
		for (;;) {
			const separator = buffer.indexOf("\r\n\r\n");
			if (separator === -1) return;
			const header = buffer.subarray(0, separator).toString("ascii");
			const match = /content-length:\s*(\d+)/i.exec(header);
			if (!match) {
				// The header is unusable. Discard it and continue.
				buffer = buffer.subarray(separator + 4);
				continue;
			}
			const end = separator + 4 + Number(match[1]);
			if (buffer.length < end) return;
			const raw = buffer.subarray(0, end);
			const body = buffer.subarray(separator + 4, end);
			buffer = buffer.subarray(end);
			let message = null;
			try {
				message = JSON.parse(body.toString("utf8"));
			} catch {
				message = null;
			}
			onMessage(message, raw);
		}
	};
}

function encode(message) {
	const body = Buffer.from(JSON.stringify(message), "utf8");
	const header = `Content-Length: ${body.length}\r\n\r\n`;
	return Buffer.concat([Buffer.from(header, "ascii"), body]);
}

// Server to client. Record which requests ask for the configuration, then send
// the bytes on without a change.
server.stdout.on(
	"data",
	createParser((message, raw) => {
		if (
			message &&
			message.method === "workspace/configuration" &&
			message.id !== undefined &&
			message.id !== null
		) {
			pending.add(message.id);
		}
		process.stdout.write(raw);
	}),
);

// Client to server. Add the workspace folder to each configuration item.
//
// A reply has no `method` field. This test is necessary because the client and
// the server each count their requests separately, so the same identifier can
// belong to a request from the client and to a request from the server.
process.stdin.on(
	"data",
	createParser((message, raw) => {
		const isReply =
			message !== null &&
			message.method === undefined &&
			message.id !== undefined &&
			pending.has(message.id);

		if (!isReply || !Array.isArray(message.result)) {
			if (isReply) pending.delete(message.id);
			server.stdin.write(raw);
			return;
		}

		pending.delete(message.id);
		// The spread puts `item` last, so an explicit value in the Helix
		// configuration stays in control.
		message.result = message.result.map((item) =>
			item !== null && typeof item === "object" && !Array.isArray(item)
				? { workspaceFolder, ...item }
				: item,
		);
		server.stdin.write(encode(message));
	}),
);

process.stdin.on("end", () => server.stdin.end());
server.on("exit", (code, signal) => process.exit(signal ? 1 : (code ?? 0)));
server.on("error", (err) => {
	process.stderr.write(`eslint proxy: ${err.message}\n`);
	process.exit(2);
});
