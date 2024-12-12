#!/bin/bash

iadm() {
    IADM_DIR="$HOME/.config/instantos/yadm" iadm_backend "$@"
}

iadm-dev() {
    IADM_DIR="$HOME/.config/instantos/yadm-dev" iadm_backend "$@"
}

iadm_backend() {
    yadm --yadm-data "$IADM_DIR" \
        --yadm-bootstrap "$IADM_DIR/bootstrap" \
        --yadm-archive "$IADM_DIR/archive" \
        "$@"
}

commit_local() {
    LOCALFILES="$(iadm diff --name-only)"
    if [ -z "$LOCALFILES" ]; then
        echo "nothing to commit"
        return
    fi
    iadm add -u
    local commit_message="Auto-commit: Update dotfiles"
    local file_count=$(echo "$LOCALFILES" | wc -l)
    # If there are few files, include their names in the commit message
    if [[ $file_count -le 5 ]]; then
        commit_message+=" (${file_count} file(s)): 
$(echo "$LOCALFILES" | sed 's/^/- /')"
    else
        commit_message+=" (${file_count} files)"
    fi

    iadm commit -m "$commit_message"
    echo "Successfully committed ${file_count} modified file(s)."
}

pull_with_ours() {
    iadm fetch
    iadm merge --strategy=recursive --strategy-option=ours origin/main --no-edit
}

update_dotfiles() {
    commit_local
    pull_with_ours
}
