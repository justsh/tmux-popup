#!/usr/bin/env bash
case "$1" in
    "create")
        session="$(tmux display -p '#S')"
        popup_session="_popup_$session"

        if ! tmux has -t "$popup_session" 2> /dev/null; then
            session_id="$(tmux new-session -dP -s "$popup_session" -F '#{session_id}')"
            # use the popup keytable, lets us set keymaps that only apply to popups in the conf file
            tmux set-option -s -t "$session_id" key-table popup
            # no need to show status bar in the popup window
            tmux set-option -s -t "$session_id" status off
            # ensure the detach hook is fired when exiting the popup window process,
            # even if the user otherwise has configured "detach-on-destroy off"
            # for regular session windows.
            tmux set-option -s -t "$session_id" detach-on-destroy on
            popup_session="$session_id"
        fi

        exec tmux attach -t "$popup_session" > /dev/null
        ;;
    "cleanup")
        # loop over all of the _popup_ sessions to check that they have the related session
        for ses in $(tmux ls -F'#S' -f '#{?#{m:_popup_*,#{session_name}},1,0}');
        do
            related_session=$(echo $ses | awk 'sub("_popup_", "")')
            # if the session is missing a related session then kill it
            if ! tmux has -t "$related_session" 2> /dev/null; then
                tmux kill-session -t "$ses"
            fi
        done
        ;;
esac
