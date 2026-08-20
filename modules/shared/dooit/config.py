from dooit.api.theme import DooitThemeBase
from dooit.ui.api import DooitAPI, subscribe
from dooit.ui.api.events import Startup
from dooit.ui.api.widgets import TodoWidget, WorkspaceWidget
from dooit_extras.bar_widgets import Clock, CurrentWorkspace, Mode, Spacer, WorkspaceProgress
from dooit_extras.formatters import (
    description_strike_completed,
    due_casual_format,
    due_icon,
    status_icons,
    urgency_icons,
)


class TokyoNight(DooitThemeBase):
    _name = "tokyo-night"

    background1 = "#1a1b26"  # bg
    background2 = "#292e42"  # bg_highlight
    background3 = "#3b4261"  # fg_gutter

    foreground1 = "#565f89"  # comment
    foreground2 = "#a9b1d6"  # fg_dark
    foreground3 = "#c0caf5"  # fg

    red     = "#f7768e"
    orange  = "#ff9e64"
    yellow  = "#e0af68"
    green   = "#9ece6a"
    blue    = "#7aa2f7"
    purple  = "#bb9af7"
    magenta = "#bb9af7"
    cyan    = "#7dcfff"

    primary   = "#7aa2f7"  # blue
    secondary = "#73daca"  # teal


@subscribe(Startup)
def setup_theme(api: DooitAPI, _: Startup):
    api.css.set_theme(TokyoNight)


@subscribe(Startup)
def setup_layout(api: DooitAPI, _: Startup):
    api.layouts.workspace_layout = [WorkspaceWidget.description]
    api.layouts.todo_layout = [
        TodoWidget.status,
        TodoWidget.description,
        TodoWidget.due,
        TodoWidget.urgency,
    ]


@subscribe(Startup)
def setup_formatters(api: DooitAPI, _: Startup):
    api.formatter.todos.status.add(status_icons(completed="✓", pending="○", overdue="!"))
    api.formatter.todos.description.add(description_strike_completed)
    api.formatter.todos.due.add(due_icon)
    api.formatter.todos.due.add(due_casual_format)
    api.formatter.todos.urgency.add(urgency_icons)


@subscribe(Startup)
def setup_bar(api: DooitAPI, _: Startup):
    bar_widgets = [
        Mode(api),
        Spacer(api, 1),
        CurrentWorkspace(api, fmt=" {} "),
        WorkspaceProgress(api, fmt=" {}% "),
        Clock(api, format="%H:%M"),
    ]
    api.bar.set(bar_widgets)


@subscribe(Startup)
def setup_keys(api: DooitAPI, _: Startup):
    api.keys.set("<tab>", api.switch_focus)
    api.keys.set("j", api.move_down)
    api.keys.set("k", api.move_up)
    api.keys.set("i", api.edit_description)
    api.keys.set("d", api.edit_due)
    api.keys.set("r", api.edit_recurrence)
    api.keys.set("e", api.edit_effort)
    api.keys.set("a", api.add_sibling)
    api.keys.set("A", api.add_child_node)
    api.keys.set("z", api.toggle_expand)
    api.keys.set("Z", api.toggle_expand_parent)
    api.keys.set("gg", api.go_to_top)
    api.keys.set("G", api.go_to_bottom)
    api.keys.set("J", api.shift_down)
    api.keys.set("K", api.shift_up)
    api.keys.set("xx", api.remove_node)
    api.keys.set("y", api.copy_description_to_clipboard)
    api.keys.set("Y", api.copy_model)
    api.keys.set("p", api.paste_model_below)
    api.keys.set("P", api.paste_model_above)
    api.keys.set("c", api.toggle_complete)
    api.keys.set(["=", "+"], api.increase_urgency)
    api.keys.set(["-", "_"], api.decrease_urgency)
    api.keys.set("/", api.start_search)
    api.keys.set("<ctrl+s>", api.start_sort)
    api.keys.set("<ctrl+q>", api.quit)
    api.keys.set("?", api.show_help)
