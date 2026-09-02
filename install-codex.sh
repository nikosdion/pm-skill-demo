#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="pm-skill-demo"
INSTALL_ROOT="$HOME/plugins"
INSTALL_DIR="$INSTALL_ROOT/$PLUGIN_NAME"
MARKETPLACE="$HOME/.agents/plugins/marketplace.json"

mkdir -p "$INSTALL_ROOT" "$(dirname "$MARKETPLACE")"
mkdir -p "$INSTALL_DIR"

rsync -a --delete \
  --exclude "/.claude" \
  --exclude "/.qwen" \
  --exclude "/.git" \
  --exclude "/.idea" \
  --exclude "/.staging" \
  --exclude "/AGENTS.md" \
  --exclude "/CLAUDE.md" \
  --exclude "/pm-skill-demo.zip" \
  "$SCRIPT_DIR/" "$INSTALL_DIR/"

MARKETPLACE="$MARKETPLACE" php -r '
$path = getenv("MARKETPLACE");
$data = file_exists($path)
    ? json_decode(file_get_contents($path), true, 512, JSON_THROW_ON_ERROR)
    : [
        "name" => "personal",
        "interface" => ["displayName" => "Personal"],
        "plugins" => [],
    ];

$entry = [
    "name" => "pm-skill-demo",
    "source" => [
        "source" => "local",
        "path" => "./plugins/pm-skill-demo",
    ],
    "policy" => [
        "installation" => "AVAILABLE",
        "authentication" => "ON_INSTALL",
    ],
    "category" => "Developer Tools",
];

$found = false;
foreach ($data["plugins"] as $index => $plugin) {
    if (($plugin["name"] ?? null) === $entry["name"]) {
        $data["plugins"][$index] = $entry;
        $found = true;
        break;
    }
}

if (!$found) {
    $data["plugins"][] = $entry;
}

file_put_contents(
    $path,
    json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . "\n"
);
'

codex plugin add "$PLUGIN_NAME@personal"

echo "Installed $PLUGIN_NAME for Codex. Start a new conversation to load it."
