#!/usr/bin/env python3
"""Runtime tests for the Helix language servers.

The tests start each server the way Helix starts it and examine the reply to
the `initialize` request. The tests also examine the local-first wrappers.

Helix starts each server in the workspace root. See helix-lsp/src/client.rs,
which calls `.current_dir(&root_path)`. Each wrapper therefore searches upwards
from the current directory to find `node_modules/.bin`.

Run the tests through the Helix wrapper, because the wrapper supplies the PATH:

    hx --help >/dev/null && ./lsp-runtime.py

Or supply the PATH directly:

    nix run nixpkgs#python3 -- modules/shared/helix/tests/lsp-runtime.py
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading

TIMEOUT = 120

# The configuration that the Helix module sends to the ESLint server.
ESLINT_CONFIG = {
    "validate": "on",
    "run": "onType",
    "workingDirectory": {"mode": "auto"},
    "format": {"enable": False},
    "codeActionsOnSave": {"mode": "all", "source.fixAll.eslint": True},
}

# Servers that must start quickly and need no network access. Each name and
# each argument list is the same as the one in the Helix configuration.
FAST_SERVERS = {
    "nixd-local": [],
    "typescript-language-server-local": ["--stdio"],
    "vscode-eslint-language-server-local": ["--stdio"],
    "tailwindcss-language-server-local": ["--stdio"],
}

# Roslyn comes from nixpkgs, so it needs no network access. The .NET runtime
# takes several seconds to start, so this server stays separate.
ROSLYN = ("roslyn-language-server-local", ["--stdio", "--autoLoadProjects"])

# Only these servers can come from `node_modules/.bin`.
NODE_WRAPPERS = [
    "typescript-language-server-local",
    "vscode-eslint-language-server-local",
    "tailwindcss-language-server-local",
]

WRAPPERS = list(FAST_SERVERS) + [ROSLYN[0], "prettierd"]

results: list[tuple[bool, str, str]] = []


def record(ok: bool, name: str, detail: str = "") -> None:
    results.append((ok, name, detail))


def lsp_initialize(command: list[str], root: str) -> dict:
    """Start a server, send `initialize`, and return the server capabilities."""
    proc = subprocess.Popen(
        command,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        cwd=root,
    )
    try:
        request = json.dumps(
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "processId": os.getpid(),
                    "rootUri": "file://" + root,
                    "clientInfo": {"name": "helix"},
                    # These values must stay the same as the values that Helix
                    # sends. See helix-lsp/src/client.rs, which sends
                    # `dynamic_registration: Some(false)` and
                    # `related_document_support: Some(true)`. A server can use
                    # the dynamic registration flag to decide whether it puts a
                    # capability in this reply or sends it later through
                    # `client/registerCapability`. A wrong value here makes the
                    # test read a capability as absent when it is present.
                    "capabilities": {
                        "textDocument": {
                            "diagnostic": {
                                "dynamicRegistration": False,
                                "relatedDocumentSupport": True,
                            }
                        },
                        "workspace": {"diagnostics": {"refreshSupport": True}},
                    },
                },
            }
        ).encode()
        proc.stdin.write(b"Content-Length: %d\r\n\r\n" % len(request) + request)
        proc.stdin.flush()

        while True:
            length = 0
            while True:
                line = proc.stdout.readline()
                if not line:
                    raise RuntimeError("the server closed the connection")
                line = line.strip()
                if line.lower().startswith(b"content-length:"):
                    length = int(line.split(b":")[1])
                elif line == b"":
                    break
            message = json.loads(proc.stdout.read(length))
            if message.get("id") == 1:
                if "error" in message:
                    raise RuntimeError(message["error"])
                return message["result"]["capabilities"]
    finally:
        proc.kill()
        proc.wait(timeout=10)


def test_wrappers_are_on_path() -> None:
    """Each wrapper must be reachable through PATH."""
    for name in WRAPPERS:
        # Arrange / Act
        found = shutil.which(name)
        # Assert
        record(found is not None, f"{name} is on PATH", found or "not found")


def test_wrapper_prefers_the_local_binary() -> None:
    """A wrapper must run `node_modules/.bin/<tool>` when that file exists."""
    for wrapper in NODE_WRAPPERS:
        tool = wrapper[: -len("-local")]
        if shutil.which(wrapper) is None:
            record(False, f"{wrapper} prefers the local binary", "wrapper not found")
            continue

        # Arrange: build a project that holds a local stand-in binary. The
        # stand-in writes a marker to a file, not to stdout. A wrapper can put a
        # proxy in front of the server, and a proxy passes on only complete
        # protocol messages, so plain text on stdout does not arrive.
        with tempfile.TemporaryDirectory() as root:
            bindir = os.path.join(root, "node_modules", ".bin")
            os.makedirs(bindir)
            marker = os.path.join(root, "marker.txt")
            local = os.path.join(bindir, tool)
            with open(local, "w") as fh:
                fh.write(f'#!/bin/sh\necho LOCAL-BINARY-RAN >> "{marker}"\n')
            os.chmod(local, 0o755)

            # A nested directory proves the wrapper searches upwards.
            nested = os.path.join(root, "packages", "app", "src")
            os.makedirs(nested)

            # Act
            subprocess.run(
                [wrapper],
                cwd=nested,
                capture_output=True,
                text=True,
                timeout=TIMEOUT,
            )

            # Assert
            found = os.path.exists(marker) and "LOCAL-BINARY-RAN" in open(marker).read()
            record(
                found,
                f"{wrapper} prefers the local binary",
                "marker written" if found else "marker missing",
            )


def test_wrapper_falls_back_to_the_nix_binary() -> None:
    """A wrapper must run the Nix binary when no local binary exists."""
    wrapper = "nixd-local"
    if shutil.which(wrapper) is None:
        record(False, f"{wrapper} falls back to the Nix binary", "wrapper not found")
        return

    # Arrange: an empty directory holds no node_modules.
    with tempfile.TemporaryDirectory() as root:
        # Act
        proc = subprocess.run(
            [wrapper, "--version"],
            cwd=root,
            capture_output=True,
            text=True,
            timeout=TIMEOUT,
        )
        # Assert
        record(
            proc.returncode == 0 and "nixd" in (proc.stdout + proc.stderr).lower(),
            f"{wrapper} falls back to the Nix binary",
            (proc.stdout + proc.stderr).strip()[:120],
        )


def test_servers_start_and_answer_initialize() -> None:
    """Each server must answer `initialize` with a usable capability set."""
    servers = dict(FAST_SERVERS)
    servers[ROSLYN[0]] = ROSLYN[1]

    for name, args in servers.items():
        if shutil.which(name) is None:
            record(False, f"{name} answers initialize", "server not found")
            continue
        with tempfile.TemporaryDirectory() as root:
            try:
                # Act
                caps = lsp_initialize([name] + args, root)
            except Exception as err:  # noqa: BLE001
                record(False, f"{name} answers initialize", str(err)[:120])
                continue
            # Assert
            record(
                bool(caps),
                f"{name} answers initialize",
                f"{len(caps)} capabilities",
            )


def test_roslyn_offers_pull_diagnostics() -> None:
    """Roslyn must advertise a diagnostic provider to a Helix-like client.

    Roslyn selects how it supplies pull diagnostics from the capability that the
    client sends. Helix sends `dynamic_registration: false`, so Roslyn must put
    `diagnosticProvider` in the initialize response. Helix enables the feature
    only when that field is present. See helix-lsp/src/client.rs,
    `LanguageServerFeature::PullDiagnostics`.

    A client that sends `dynamic_registration: true` receives no such field.
    Roslyn instead sends `client/registerCapability` later. This test therefore
    copies the Helix capability exactly.
    """
    name, args = ROSLYN
    if shutil.which(name) is None:
        record(False, f"{name} offers pull diagnostics", "server not found")
        return

    with tempfile.TemporaryDirectory() as root:
        # Arrange: Roslyn needs a project to load.
        with open(os.path.join(root, "Test.csproj"), "w") as fh:
            fh.write(
                '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
                "<TargetFramework>net8.0</TargetFramework>"
                "</PropertyGroup></Project>"
            )
        try:
            # Act
            caps = lsp_initialize([name] + args, root)
        except Exception as err:  # noqa: BLE001
            record(False, f"{name} offers pull diagnostics", str(err)[:120])
            return
        # Assert
        record(
            caps.get("diagnosticProvider") is not None,
            f"{name} offers pull diagnostics",
            json.dumps(caps.get("diagnosticProvider"))[:120],
        )


# A stand-in ESLint library. It records the working directory that the server
# chooses, so the test can prove which directory ESLint receives.
STUB_ESLINT = """\
const fs = require("fs");
const rec = (tag) =>
  fs.appendFileSync(process.env.CWD_RECORD, `${tag} ${process.cwd()}\\n`);
class ESLint {
  static version = "9.99.0";
  constructor(opts) { rec("construct"); this.opts = opts || {}; }
  async calculateConfigForFile() { return { plugins: {}, rules: {}, parser: null }; }
  async isPathIgnored() { return false; }
  async lintText() { rec("lintText"); return []; }
  static async outputFixes() {}
}
module.exports = { ESLint, Linter: class {}, loadESLint: async () => ESLint };
module.exports.FlatESLint = ESLint;
module.exports.shouldUseFlatConfig = async () => true;
"""


def build_eslint_project(root: str) -> str:
    """Create a project whose ESLint configuration sits in the root."""
    nested = os.path.join(root, "src", "components")
    os.makedirs(nested)
    stub = os.path.join(root, "node_modules", "eslint")
    os.makedirs(stub)

    def write(path: str, text: str) -> None:
        with open(path, "w") as fh:
            fh.write(text)

    write(os.path.join(root, "package.json"), '{"name":"t","version":"1.0.0"}')
    write(os.path.join(root, "tsconfig.eslint.json"), '{"include":["src"]}')
    write(
        os.path.join(root, "eslint.config.js"),
        "module.exports = [{ languageOptions: { parserOptions: "
        "{ project: ['./tsconfig.eslint.json'] } } }];",
    )
    write(os.path.join(stub, "index.js"), STUB_ESLINT)
    write(os.path.join(stub, "use-at-your-own-risk.js"), 'module.exports = require("./index.js");')
    write(
        os.path.join(stub, "package.json"),
        '{"name":"eslint","version":"9.99.0","main":"index.js","exports":'
        '{".":"./index.js","./use-at-your-own-risk":"./use-at-your-own-risk.js"}}',
    )

    target = os.path.join(nested, "Button.tsx")
    write(target, "export const Button = () => <button>hi</button>;\n")
    return target


def test_eslint_uses_the_project_root() -> None:
    """ESLint must run in the project root, not in the directory of the file.

    The server asks the client for its settings and expects a `workspaceFolder`
    field in the reply. Helix replies with a fixed configuration and ignores the
    `scopeUri` (helix-term/src/application.rs), so the field never arrives. The
    server then falls back to `path.dirname(file)` for both `auto` mode and
    `location` mode. A relative path such as `./tsconfig.eslint.json` in the
    ESLint configuration then fails to resolve.
    """
    name = "vscode-eslint-language-server-local"
    if shutil.which(name) is None:
        record(False, "eslint runs in the project root", "server not found")
        return

    with tempfile.TemporaryDirectory() as root:
        # Arrange
        root = os.path.realpath(root)
        target = build_eslint_project(root)
        record_file = os.path.join(root, "cwd-record.txt")
        open(record_file, "w").close()

        # Act
        proc = subprocess.Popen(
            [name, "--stdio"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            cwd=root,  # Helix starts the server in the workspace root.
            env=dict(os.environ, CWD_RECORD=record_file),
        )

        def send(obj: dict) -> None:
            body = json.dumps(obj).encode()
            proc.stdin.write(b"Content-Length: %d\r\n\r\n" % len(body) + body)
            proc.stdin.flush()

        def read() -> dict | None:
            length = 0
            while True:
                line = proc.stdout.readline()
                if not line:
                    return None
                line = line.strip()
                if line.lower().startswith(b"content-length:"):
                    length = int(line.split(b":")[1])
                elif line == b"":
                    return json.loads(proc.stdout.read(length))

        send(
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "processId": os.getpid(),
                    "rootUri": "file://" + root,
                    "clientInfo": {"name": "helix"},
                    "workspaceFolders": [{"uri": "file://" + root, "name": "t"}],
                    "capabilities": {
                        "workspace": {"configuration": True, "workspaceFolders": True},
                        "textDocument": {
                            "diagnostic": {
                                "dynamicRegistration": False,
                                "relatedDocumentSupport": True,
                            }
                        },
                    },
                },
            }
        )

        killer = threading.Timer(TIMEOUT, proc.kill)
        killer.start()
        try:
            while True:
                msg = read()
                if msg is None:
                    break
                if msg.get("id") == 1 and "result" in msg:
                    send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
                    send(
                        {
                            "jsonrpc": "2.0",
                            "method": "textDocument/didOpen",
                            "params": {
                                "textDocument": {
                                    "uri": "file://" + target,
                                    "languageId": "typescriptreact",
                                    "version": 1,
                                    "text": open(target).read(),
                                }
                            },
                        }
                    )
                    send(
                        {
                            "jsonrpc": "2.0",
                            "id": 2,
                            "method": "textDocument/diagnostic",
                            "params": {"textDocument": {"uri": "file://" + target}},
                        }
                    )
                    continue
                if msg.get("method") == "workspace/configuration":
                    # Helix answers every item with the same fixed configuration.
                    send(
                        {
                            "jsonrpc": "2.0",
                            "id": msg["id"],
                            "result": [ESLINT_CONFIG for _ in msg["params"]["items"]],
                        }
                    )
                    continue
                if msg.get("method") == "client/registerCapability":
                    send({"jsonrpc": "2.0", "id": msg["id"], "result": None})
                    continue
                if msg.get("id") == 2:
                    break
        finally:
            killer.cancel()
            proc.kill()
            proc.wait(timeout=10)

        # Assert
        lines = [l for l in open(record_file).read().splitlines() if l.strip()]
        used = {l.split(" ", 1)[1] for l in lines}
        if not used:
            record(False, "eslint runs in the project root", "eslint was never called")
            return
        wrong = {d for d in used if os.path.realpath(d) != root}
        record(
            not wrong,
            "eslint runs in the project root",
            "used " + ", ".join(sorted(d.replace(root, "<root>") or "<root>" for d in used)),
        )


def main() -> int:
    test_wrappers_are_on_path()
    test_wrapper_prefers_the_local_binary()
    test_wrapper_falls_back_to_the_nix_binary()
    test_servers_start_and_answer_initialize()
    test_roslyn_offers_pull_diagnostics()
    test_eslint_uses_the_project_root()

    failed = 0
    for ok, name, detail in results:
        mark = "PASS" if ok else "FAIL"
        suffix = f"  ({detail})" if detail else ""
        print(f"{mark} {name}{suffix}")
        if not ok:
            failed += 1

    print(f"\n{len(results) - failed} passed, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
