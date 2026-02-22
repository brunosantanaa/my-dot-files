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
_get_profile_location() {
    local profile_name="$1"
    python3 - "$profile_name" "$VSCODE_USER" <<'PYEOF'
import json, sys, os

profile_name = sys.argv[1]
vscode_user = sys.argv[2]
storage_path = os.path.join(vscode_user, "globalStorage", "storage.json")
try:
    with open(storage_path) as f:
        d = json.load(f)
    profiles_raw = d.get("userDataProfiles", "[]")
    profiles = json.loads(profiles_raw) if isinstance(profiles_raw, str) else profiles_raw
    for p in profiles:
        if p.get("name") == profile_name:
            print(p.get("location", ""))
            break
except Exception:
    pass
PYEOF
}

# Pass 1: Install extensions for all profiles
# Running all installs first ensures VSCode registers every profile in storage.json
# before we try to read profile locations in pass 2.
echo "==> Installing VSCode profile extensions..."
for profile_src in "$DOTFILES_DIR/vscode/profiles/"/*/; do
    profile_name=$(basename "$profile_src")
    [ -f "$profile_src/extensions.txt" ] || continue
    echo "  --> Profile: $profile_name"
    while IFS= read -r ext_id; do
        [[ -z "$ext_id" || "$ext_id" == \#* ]] && continue
        echo "      installing: $ext_id"
        code --profile "$profile_name" --install-extension "$ext_id" --force 2>/dev/null
    done < "$profile_src/extensions.txt"
done

# Pass 2: Link settings & snippets for all profiles
echo "==> Linking VSCode profile settings..."
_profiles_missing=()
for profile_src in "$DOTFILES_DIR/vscode/profiles/"/*/; do
    profile_name=$(basename "$profile_src")
    echo "  --> Profile: $profile_name"

    profile_location=$(_get_profile_location "$profile_name")

    if [ -z "$profile_location" ]; then
        _profiles_missing+=("$profile_name")
        echo "      warning: profile location not found — settings not linked"
        continue
    fi

    profile_dest="$VSCODE_USER/profiles/$profile_location"
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
done

if [ ${#_profiles_missing[@]} -gt 0 ]; then
    echo ""
    echo "  warning: settings not linked for profiles:"
    for p in "${_profiles_missing[@]}"; do
        echo "    - $p"
    done
    echo "  Open VSCode once to initialize the profiles, then re-run:"
    echo "    zsh $DOTFILES_DIR/vscode/install.zsh"
fi

echo "==> VSCode configured!"
