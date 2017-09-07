#!/bin/bash
#lucius_black="#444444"
lucius_black="#eeeeee"
#lucius_white="#eeeeee"
lucius_white="#444444"
lucius_blue="#005faf"
lucius_yellow="#af5f00"
lucius_red="#e06c75"
lucius_green="#00875f"
lucius_visual_grey="#9a9a9a"
lucius_comment_grey="#808080"

get() {
   local option=$1
   local default_value=$2
   local option_value="$(tmux show-option -gqv "$option")"

   if [ -z "$option_value" ]; then
      echo "$default_value"
   else
      echo "$option_value"
   fi
}

set() {
   local option=$1
   local value=$2
   tmux set-option -gq "$option" "$value"
}

setw() {
   local option=$1
   local value=$2
   tmux set-window-option -gq "$option" "$value"
}

set "status" "on"
set "status-justify" "left"

set "status-left-length" "100"
set "status-right-length" "100"
set "status-right-attr" "none"

set "message-fg" "$lucius_white"
set "message-bg" "$lucius_black"

set "message-command-fg" "$lucius_white"
set "message-command-bg" "$lucius_black"

set "status-attr" "none"
set "status-left-attr" "none"

setw "window-status-fg" "$lucius_black"
setw "window-status-bg" "$lucius_black"
setw "window-status-attr" "none"

setw "window-status-activity-bg" "$lucius_black"
setw "window-status-activity-fg" "$lucius_black"
setw "window-status-activity-attr" "none"

setw "window-status-separator" ""

set "window-style" "fg=$lucius_comment_grey,bg=$lucius_black"
set "window-active-style" "fg=$lucius_white,bg=$lucius_black"

set "pane-border-fg" "$lucius_white"
set "pane-active-border-fg" "$lucius_white"

set "display-panes-active-colour" "$lucius_yellow"
set "display-panes-colour" "$lucius_blue"

set "status-bg" "$lucius_black"
set "status-fg" "$lucius_white"

set "@prefix_highlight_fg" "$lucius_black"
set "@prefix_highlight_bg" "$lucius_green"
set "@prefix_highlight_copy_mode_attr" "fg=$lucius_black,bg=$lucius_green"
set "@prefix_highlight_output_prefix" "  "

status_widgets=$(get "@lucius_widgets")
time_format=$(get "@lucius_time_format" "%R")
date_format=$(get "@lucius_date_format" "%d/%m/%Y")

set "status-right" "#[fg=$lucius_white,bg=$lucius_black,nounderscore,noitalics]${time_format}  ${date_format} #[fg=$lucius_visual_grey,bg=$lucius_black]#[fg=$lucius_visual_grey,bg=$lucius_visual_grey]#[fg=$lucius_white, bg=$lucius_visual_grey]${status_widgets} #[fg=$lucius_green,bg=$lucius_visual_grey,nobold,nounderscore,noitalics]#[fg=$lucius_black,bg=$lucius_green,bold] #h #[fg=$lucius_yellow, bg=$lucius_green]#[fg=$lucius_red,bg=$lucius_yellow]"
set "status-left" "#[fg=$lucius_visual_grey,bg=$lucius_green,bold] #S #{prefix_highlight}#[fg=$lucius_green,bg=$lucius_black,nobold,nounderscore,noitalics]"

set "window-status-format" "#[fg=$lucius_black,bg=$lucius_black,nobold,nounderscore,noitalics]#[fg=$lucius_white,bg=$lucius_black] #I  #W #[fg=$lucius_black,bg=$lucius_black,nobold,nounderscore,noitalics]"
set "window-status-current-format" "#[fg=$lucius_black,bg=$lucius_visual_grey,nobold,nounderscore,noitalics]#[fg=$lucius_white,bg=$lucius_visual_grey,nobold] #I  #W #[fg=$lucius_visual_grey,bg=$lucius_black,nobold,nounderscore,noitalics]"
