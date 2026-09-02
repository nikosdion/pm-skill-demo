#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/pm-skill-demo.zip"
STAGING="$SCRIPT_DIR/.staging"

# ---------------------------------------------------------------------------
# Build a clean staging copy so the source tree is never modified.
# ---------------------------------------------------------------------------
rm -rf "$STAGING"
mkdir -p "$STAGING"
# Copy everything except the staging dir itself and generated artifacts.
rsync -a \
  --exclude "/.claude" \
  --exclude "/.qwen" \
  --exclude "/.git" \
  --exclude "/.staging" \
  --exclude "/.idea" \
  --exclude "/AGENTS.md" \
  --exclude "/CLAUDE.md" \
  --exclude "/pm-skill-demo.zip" \
  --exclude "/install-qwen.sh" \
  "$SCRIPT_DIR/" "$STAGING/"

# ---------------------------------------------------------------------------
# Zip from the staging directory.
# ---------------------------------------------------------------------------
rm -f "$OUTPUT"

cd "$STAGING"
zip -r "$OUTPUT" . \
  --exclude "./install-claude.sh" \
  --exclude "./install-codex.sh" \
  --exclude "./install-qwen.sh" \
  --exclude "./pm-skill-demo.zip" \
  --exclude "./.claude" \
  --exclude "./.gitignore" \
  --exclude "./.git" \
  --exclude "./.git/*" \
  --exclude "./.idea" \
  --exclude "./.idea/*" \
  --exclude "./.staging/*"

cd "$SCRIPT_DIR"
rm -rf "$STAGING"

echo "Created $OUTPUT"

# ---------------------------------------------------------------------------
# Unzip into ~/.claude-plugins
# ---------------------------------------------------------------------------
mkdir -p ~/.claude-plugins 2>/dev/null
rm -rf ~/.claude-plugins/pm-skill-demo 2>/dev/null
# Note: do NOT pipe `yes` into unzip. When unzip exits, `yes` dies of SIGPIPE,
# which under `set -o pipefail` makes the pipeline return 141 and `set -e`
# aborts the script before the marketplace registration below ever runs.
unzip -o pm-skill-demo.zip -d ~/.claude-plugins/pm-skill-demo

# ---------------------------------------------------------------------------
# Ensure ~/.claude-plugins/marketplace.json exists.
# ---------------------------------------------------------------------------
MARKETPLACE="$HOME/.claude-plugins/.claude-plugin/marketplace.json"

if [ ! -f "$MARKETPLACE" ]; then
  cat > "$MARKETPLACE" <<'EOF'
{
  "name": "local",
  "owner": { "name": "Niko" },
  "plugins": [
  ]
}
EOF
fi

# ---------------------------------------------------------------------------
# Ensure ~/.claude-plugins/marketplace.json contains this plugin.
# ---------------------------------------------------------------------------

php -r '
$path = getenv("HOME") . "/.claude-plugins/.claude-plugin/marketplace.json";
$data = json_decode(file_get_contents($path), true);

$entry = [
  "name"        => "pm-skill-demo",
  "source"      => "./pm-skill-demo",
  "description" => "AI coding assistant skills for managing Joomla software projects",
];

$found = false;
foreach ($data["plugins"] as $plugin) {
  if ($plugin["name"] === $entry["name"]) {
    $found = true;
    break;
  }
}

if (!$found) {
  $data["plugins"][] = $entry;
  file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");
  echo "Added pm-skill-demo to marketplace.json\n";
} else {
  echo "pm-skill-demo already present in marketplace.json\n";
}
'

# ---------------------------------------------------------------------------
# Remove and re-add the local marketplace.
#
# This works around a known bug in Claude Code which prevents it from
# updating local marketplaces.
# ---------------------------------------------------------------------------
claude plugin marketplace add ~/.claude-plugins
claude plugin marketplace update local
claude plugin install pm-skill-demo@local
# `install` is a no-op once the plugin is installed, and the plugin cache is keyed
# by the version in .claude-plugin/plugin.json — so bump that version whenever you
# change plugin content, and let `update` pull the new version into the cache.
# Without this the cache keeps serving the previously installed version forever.
claude plugin update pm-skill-demo@local
