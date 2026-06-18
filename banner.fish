#!/usr/bin/fish
#
# Shared helper for the update scripts.
#
# print_banner prints a three-line, full-width banner so that when several
# update scripts run back-to-back it is obvious where each one's output begins:
#
#   ========================================
#   Updating Navidrome: 0.61.0 -> 0.62.0
#   ========================================
#
# The rule width follows the terminal when attached to one (so it still looks
# right in a narrow phone session) and falls back to 80 columns otherwise.
# Output is bold cyan on a terminal and plain text when piped or logged.

function print_banner --argument-names message
    set -l width 80
    if isatty stdout
        set -l cols (tput cols 2>/dev/null)
        test -n "$cols"; and set width $cols
    end

    set -l line (string repeat -n $width =)

    if isatty stdout
        set_color --bold cyan
        printf '%s\n%s\n%s\n' $line $message $line
        set_color normal
    else
        printf '%s\n%s\n%s\n' $line $message $line
    end
end
