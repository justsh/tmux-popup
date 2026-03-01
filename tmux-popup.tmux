#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

source "$SCRIPTS_DIR/variables.sh"

set_key_binds() {
    local key="$(get_tmux_option "$POPUP_KEY_OPTION" "$POPUP_DEFAULT_KEY")"
    local table="$(get_tmux_option "$POPUP_TABLE_OPTION" "$POPUP_DEFAULT_TABLE")"
    local border="$(get_tmux_option "$POPUP_BORDER_OPTION" "$POPUP_DEFAULT_BORDER")"
    local height="$(get_tmux_option "$POPUP_HEIGHT_OPTION" "$POPUP_DEFAULT_HEIGHT")"
    local width="$(get_tmux_option "$POPUP_WIDTH_OPTION" "$POPUP_DEFAULT_WIDTH")"
    # scratch popup
    tmux bind-key -T "$table" "$key" display-popup -E -b "$border" -h "$height" -w "$width" "${SCRIPTS_DIR}/tmux_popup.sh create"
    # close the popup with the same keymap used to open it
    tmux bind-key -T popup "$key" detach

    # hide the popup sessions when choosing sessions
    tmux bind-key s choose-tree -Zs -f '#{?#{m:_popup_*,#{session_name}},0,1}'
    tmux bind-key w choose-tree -Zw -f '#{?#{m:_popup_*,#{session_name}},0,1}'
}

# cleanup the persistent sessions used for the popup windows
tmux set-hook -g client-detached "run-shell '$SCRIPTS_DIR/tmux_popup.sh cleanup'"
tmux set-hook -g session-closed "run-shell '$SCRIPTS_DIR/tmux_popup.sh cleanup'"

set_key_binds
