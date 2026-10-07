#!/usr/bin/env bash
# Speed comparison: PHPStan vs Mago, analyzing Laravel and Symfony framework source.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TOOLS="$ROOT/tools"
RESULTS="$ROOT/results"
RUNS="${RUNS:-1}"
PROJECTS=(laravel symfony)

mkdir -p "$RESULTS"
TIME_BIN=/usr/bin/time
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# median <values...> -> median of the elapsed seconds (float)
median() {
    printf '%s\n' "$@" | sort -n | awk '{a[NR]=$1} END {n=NR; print (n%2) ? a[(n+1)/2] : (a[n/2]+a[n/2+1])/2}'
}

# run_once <maxrss_out_file> <command...> -> prints elapsed seconds, writes peak RSS (KB) to file
run_once() {
    local rss_file="$1"; shift
    "$TIME_BIN" -f '%e %M' -o "$TMP/t" "$@" >/dev/null 2>&1 || true
    read -r elapsed rss <<<"$(tail -1 "$TMP/t")"
    echo "${rss:-0}" > "$rss_file"
    echo "${elapsed:-0}"
}

phpstan_cmd() { php "$TOOLS/phpstan.phar" analyse -c phpstan.neon --no-progress --error-format=raw; }
mago_cmd() { "$TOOLS/mago" analyze; }

# bench <tool> <mode> : prints "median_seconds peak_mb"
bench() {
    local tool="$1" mode="$2"
    local times=() rss_max=0
    for _ in $(seq "$RUNS"); do
        # cold mode: wipe PHPStan result cache before each run (Mago keeps no cache)
        if [ "$mode" = cold ] && [ "$tool" = phpstan ]; then rm -rf .phpstan-cache; fi
        if [ "$tool" = phpstan ]; then
            t=$(run_once "$TMP/rss" php "$TOOLS/phpstan.phar" analyse -c phpstan.neon --no-progress --error-format=raw)
        else
            t=$(run_once "$TMP/rss" "$TOOLS/mago" analyze)
        fi
        times+=("$t")
        r=$(cat "$TMP/rss")
        if [ "${r:-0}" -gt "$rss_max" ]; then rss_max="$r"; fi
    done
    local med; med=$(median "${times[@]}")
    awk -v s="$med" -v m="$rss_max" 'BEGIN{printf "%.2f %.0f\n", s, m/1024}'
}

OUT="$RESULTS/results.md"
{
    echo "# Results"
    echo
    echo "- Host: \`$(uname -sr)\`, PHP \`$(php -r 'echo PHP_VERSION;')\`"
    echo "- PHPStan \`$(php "$TOOLS/phpstan.phar" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')\` (level 2), Mago \`$("$TOOLS/mago" --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')\` (analyze)"
    echo "- Runs per cell: $RUNS (median reported). Time in seconds, peak memory in MB."
    echo
    echo "| Project | Files (src) | Tool | Cold (s) | Hot (s) | Peak mem (MB) |"
    echo "|---------|------------:|------|---------:|--------:|--------------:|"
} > "$OUT"

for proj in "${PROJECTS[@]}"; do
    cd "$ROOT/projects/$proj"
    files=$(find src -name '*.php' | wc -l | tr -d ' ')
    echo ">>> $proj: PHPStan"
    read -r ps_cold ps_mem_c < <(bench phpstan cold)
    read -r ps_hot ps_mem_h < <(bench phpstan hot)
    ps_mem=$(( ps_mem_c > ps_mem_h ? ps_mem_c : ps_mem_h ))
    echo ">>> $proj: Mago"
    read -r mg_cold mg_mem_c < <(bench mago cold)
    read -r mg_hot mg_mem_h < <(bench mago hot)
    mg_mem=$(( mg_mem_c > mg_mem_h ? mg_mem_c : mg_mem_h ))
    {
        echo "| $proj | $files | PHPStan | $ps_cold | $ps_hot | $ps_mem |"
        echo "| $proj | $files | Mago | $mg_cold | $mg_hot | $mg_mem |"
    } >> "$OUT"
done

cd "$ROOT"
echo
cat "$OUT"
