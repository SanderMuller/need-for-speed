#!/usr/bin/env bash
# Install tools and clone + prepare the target projects. Run once before bench.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TOOLS="$ROOT/tools"
PHPSTAN_VERSION="${PHPSTAN_VERSION:-2.3.0}"

mkdir -p "$TOOLS" "$ROOT/projects"

echo ">>> Installing Mago"
curl -sSL https://carthage.software/mago.sh | bash -s -- --install-dir="$TOOLS"

echo ">>> Downloading PHPStan $PHPSTAN_VERSION"
curl -sSL -o "$TOOLS/phpstan.phar" \
    "https://github.com/phpstan/phpstan/releases/download/$PHPSTAN_VERSION/phpstan.phar"

clone_project() {
    local name="$1" repo="$2"
    if [ ! -d "$ROOT/projects/$name/.git" ]; then
        echo ">>> Cloning $name"
        git clone --depth 1 "$repo" "$ROOT/projects/$name"
    fi
    echo ">>> composer install: $name"
    (cd "$ROOT/projects/$name" && COMPOSER_MEMORY_LIMIT=-1 \
        composer install --no-interaction --no-progress --no-scripts --ignore-platform-reqs)
    cp "$ROOT/configs/$name/phpstan.neon" "$ROOT/projects/$name/phpstan.neon"
    cp "$ROOT/configs/$name/mago.toml" "$ROOT/projects/$name/mago.toml"
}

clone_project laravel https://github.com/laravel/framework.git
clone_project symfony https://github.com/symfony/symfony.git

echo ">>> Done. Now run: ./bench.sh"
