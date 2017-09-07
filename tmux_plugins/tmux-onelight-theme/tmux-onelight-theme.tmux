#!/usr/bin/env bash
onelight_black="#282c34"
onelight_blue="#61afef"
onelight_yellow="#e5c07b"
onelight_red="#e06c75"
onelight_white="#aab2bf"
onelight_green="#98c379"
onelight_visual_grey="#3e4452"
onelight_comment_grey="#5c6370"

get_widgets() {
   echo "$(tmux show-option -gqv "@onelight_widgets")"
}

sett() {
   local option=$1
   local value=$2
   tmux set-option -gq "$option" "$value"
}

setw() {
   local option=$1
   local value=$2
   tmux set-window-option -gq "$option" "$value"
}

sett "status" "on"
sett "status-justify" "left"

sett "status-left-length" "100"
sett "status-right-length" "100"
sett "status-right-attr" "none"

sett "message-fg" "$onelight_white"
sett "message-bg" "$onelight_black"

sett "message-command-fg" "$onelight_white"
sett "message-command-bg" "$onelight_black"

sett "status-attr" "none"
sett "status-left-attr" "none"

setw "window-status-fg" "$onelight_black"
setw "window-status-bg" "$onelight_black"
setw "window-status-attr" "none"

setw "window-status-activity-bg" "$onelight_black"
setw "window-status-activity-fg" "$onelight_black"
setw "window-status-activity-attr" "none"

setw "window-status-separator" ""

sett "window-style" "fg=#5c6370,bg=$onelight_white"
sett "window-active-style" "fg=$onelight_black,bg=$onelight_white"

sett "pane-border-fg" "$onelight_white"
sett "pane-active-border-fg" "$onelight_white"

sett "display-panes-active-colour" "$onelight_yellow"
sett "display-panes-colour" "$onelight_blue"

sett "status-bg" "$onelight_black"
sett "status-fg" "$onelight_white"

sett "@prefix_highlight_fg" "$onelight_white"
sett "@prefix_highlight_bg" "$onelight_green"
sett "@prefix_highlight_copy_mode_attr" "fg=$onelight_white,bg=$onelight_green"
sett "@prefix_highlight_output_prefix" "  "

sett "status-right" "#[fg=$onelight_white,bg=$onelight_black,nounderscore,noitalics]%H:%M  %d/%m/%y #[fg=$onelight_visual_grey,bg=$onelight_black]#[fg=$onelight_visual_grey,bg=$onelight_visual_grey]#[fg=$onelight_white, bg=$onelight_visual_grey]$(get_widgets) #[fg=$onelight_green,bg=$onelight_visual_grey,nobold,nounderscore,noitalics]#[fg=$onelight_black,bg=$onelight_green,bold] #h #[fg=$onelight_yellow, bg=$onelight_green]#[fg=$onelight_red,bg=$onelight_yellow]"
sett "status-left" "#[fg=$onelight_visual_grey,bg=$onelight_green,bold] #S #{prefix_highlight}#[fg=$onelight_green,bg=$onelight_black,nobold,nounderscore,noitalics]"

sett "window-status-format" "#[fg=$onelight_black,bg=$onelight_black,nobold,nounderscore,noitalics]#[fg=$onelight_white,bg=$onelight_black] #I  #W #[fg=$onelight_black,bg=$onelight_black,nobold,nounderscore,noitalics]"
sett "window-status-current-format" "#[fg=$onelight_black,bg=$onelight_visual_grey,nobold,nounderscore,noitalics]#[fg=$onelight_white,bg=$onelight_visual_grey,nobold] #I  #W #[fg=$onelight_visual_grey,bg=$onelight_black,nobold,nounderscore,noitalics]"
