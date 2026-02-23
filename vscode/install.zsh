#!/bin/zsh
# VSCode settings, keybindings, snippets and profiles installer

DOTFILES_DIR="${1:-$HOME/.dotfiles}"
if [[ "$(uname -s)" == "Darwin" ]]; then
    VSCODE_USER="$HOME/Library/Application Support/Code/User"
else
    VSCODE_USER="$HOME/.config/Code/User"
fi

# ─── Check VSCode ──────────────────────────────────────────────────────────────
if ! command -v code &>/dev/null; then
    echo "  VSCode (code) not found in PATH, skipping"
    exit 0
fi

# ─── Default profile: settings & keybindings ──────────────────────────────────
echo "==> Linking VSCode default settings..."
for file in settings.json keybindings.json; do
    src="$DOTFILES_DIR/vscode/$file"
    dest="$VSCODE_USER/$file"
    [ -L "$dest" ] && rm "$dest"
    [ -f "$dest" ] && mv "$dest" "${dest}.backup"
    ln -s "$src" "$dest"
    echo "  linked: $file"
done

# ─── Default profile: snippets ────────────────────────────────────────────────
if ls "$DOTFILES_DIR/vscode/snippets/"*.json &>/dev/null; then
    echo "==> Linking VSCode default snippets..."
    mkdir -p "$VSCODE_USER/snippets"
    for snippet in "$DOTFILES_DIR/vscode/snippets/"*.json; do
        name=$(basename "$snippet")
        dest="$VSCODE_USER/snippets/$name"
        [ -L "$dest" ] && rm "$dest"
        [ -f "$dest" ] && mv "$dest" "${dest}.backup"
        ln -s "$snippet" "$dest"
        echo "  linked: snippets/$name"
    done
fi

# ─── Profiles ─────────────────────────────────────────────────────────────────
# Register a profile in storage.json (creates it if missing) and return its location ID.
# Uses a deterministic 8-char hex ID derived from the profile name so IDs are
# stable and reproducible across machines.
_ensure_profile() {
    local profile_name="$1"
    python3 - "$profile_name" "$VSCODE_USER" <<'PYEOF'
import json, sys, os, hashlib

profile_name = sys.argv[1]
vscode_user  = sys.argv[2]
storage_path = os.path.join(vscode_user, "globalStorage", "storage.json")

with open(storage_path) as f:
    d = json.load(f)

profiles = d.get("userDataProfiles", [])
if isinstance(profiles, str):
    profiles = json.loads(profiles)

# Return existing location if profile already registered
for p in profiles:
    if p.get("name") == profile_name:
        print(p.get("location", ""))
        sys.exit(0)

# Generate a deterministic 8-char hex ID from the profile name
profile_id = hashlib.md5(profile_name.encode()).hexdigest()[:8]

profiles.append({"name": profile_name, "location": profile_id})
d["userDataProfiles"] = profiles

with open(storage_path, "w") as f:
    json.dump(d, f, indent=2)

# Create the profile directory so VSCode and the code CLI recognize it
profile_dir = os.path.join(vscode_user, "profiles", profile_id)
os.makedirs(profile_dir, exist_ok=True)

print(profile_id)
PYEOF
}

echo "==> Configuring VSCode profiles..."
for profile_src in "$DOTFILES_DIR/vscode/profiles/"/*/; do
    profile_name=$(basename "$profile_src")
    echo "  --> Profile: $profile_name"

    profile_id=$(_ensure_profile "$profile_name")
    profile_dest="$VSCODE_USER/profiles/$profile_id"
    mkdir -p "$profile_dest/snippets"

    # Link settings.json
    if [ -f "$profile_src/settings.json" ]; then
        dest="$profile_dest/settings.json"
        [ -L "$dest" ] && rm "$dest"
        [ -f "$dest" ] && mv "$dest" "${dest}.backup"
        ln -s "$profile_src/settings.json" "$dest"
        echo "      linked: settings.json"
    fi

    # Link snippets
    if ls "$profile_src/snippets/"*.json &>/dev/null; then
        for snippet in "$profile_src/snippets/"*.json; do
            [ -f "$snippet" ] || continue
            name=$(basename "$snippet")
            dest="$profile_dest/snippets/$name"
            [ -L "$dest" ] && rm "$dest"
            [ -f "$dest" ] && mv "$dest" "${dest}.backup"
            ln -s "$snippet" "$dest"
            echo "      linked: snippets/$name"
        done
    fi

    # Install extensions (profile now exists so code CLI accepts --profile)
    if [ -f "$profile_src/extensions.txt" ]; then
        while IFS= read -r ext_id; do
            [[ -z "$ext_id" || "$ext_id" == \#* ]] && continue
            echo "      installing: $ext_id"
            code --profile "$profile_name" --install-extension "$ext_id" --force 2>/dev/null
        done < "$profile_src/extensions.txt"
    fi
done

# ─── Inject author info for doxygen (local only, not stored in repo) ──────────
_inject_author_settings() {
    local settings_file="$1" author_name="$2" author_email="$3"
    [ -f "$settings_file" ] || return
    python3 - "$settings_file" "$author_name" "$author_email" <<'PYEOF'
import json, sys, os
path, name, email = sys.argv[1], sys.argv[2], sys.argv[3]
# Materialize symlink so we don't modify the repo file
if os.path.islink(path):
    content = open(os.path.realpath(path)).read()
    os.unlink(path)
    with open(path, 'w') as f:
        f.write(content)
with open(path) as f:
    d = json.load(f)
d["doxdocgen.generic.authorName"] = name
d["doxdocgen.generic.authorEmail"] = email
with open(path, 'w') as f:
    json.dump(d, f, indent=4)
PYEOF
}

echo ""
echo "==> Author info for doxygen comments (stored locally, not in repo)"
read "AUTHOR_NAME?  Name  (leave blank to skip): "
if [[ -n "$AUTHOR_NAME" ]]; then
    read "AUTHOR_EMAIL?  Email: "

    _inject_author_settings "$VSCODE_USER/settings.json" "$AUTHOR_NAME" "$AUTHOR_EMAIL"
    echo "  injected into: default profile"

    for profile_src in "$DOTFILES_DIR/vscode/profiles/"/*/; do
        profile_name=$(basename "$profile_src")
        [ -f "$profile_src/settings.json" ] || continue
        profile_id=$(_ensure_profile "$profile_name")
        _inject_author_settings \
            "$VSCODE_USER/profiles/$profile_id/settings.json" \
            "$AUTHOR_NAME" "$AUTHOR_EMAIL"
        echo "  injected into: $profile_name"
    done
fi

echo "==> VSCode configured!"
