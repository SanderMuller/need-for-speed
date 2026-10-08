# need-for-speed

Speed comparison of PHP code-quality tools on real framework source:
static analysis with **[PHPStan](https://phpstan.org/)** (PHP) vs **[Mago](https://github.com/carthage-software/mago)** (Rust),
and coding-standard checks with **[ECS](https://github.com/easy-coding-standard/easy-coding-standard)**
in both engines - the PHP engine (`check`) and the bundled Go binary (`check --blink`).
All run against Laravel and Symfony `src/`. Inspired by
[php-toolchain-benchmarks](https://github.com/carthage-software/php-toolchain-benchmarks), kept minimal.

## Results

PHP 8.4.26, all tools pinned to 24 threads/processes, median of 3 runs.
PHPStan at level 8; Mago `analyze` with strict toggles (Mago has no numeric levels); ECS at PSR-12.
**Cold** = fresh run; **Hot** = immediate re-run (PHPStan and ECS reuse a result cache; Mago and ECS `--blink` keep none).
PHPStan rows were measured on host `Linux 7.0.0-31-generic`; the Mago `1.53.0` and ECS rows were
measured on `Linux 7.0.0-38-generic`, so absolute numbers are not strictly host-matched across tools.

| Project | PHP | Files | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|----:|------:|------|---------|---------:|--------:|--------------:|
| Laravel | 8.4 | 1707 | PHPStan | 2.3.0 | 33.75 | 1.69 | 389 |
| Laravel | 8.4 | 1707 | Mago | 1.53.0 | 1.04 | 1.05 | 2228 |
| Laravel | 8.4 | 1707 | ECS | 13.3.3 | 9.03 | 9.17 | 68 |
| Laravel | 8.4 | 1707 | ECS --blink | 13.3.3 | 0.78 | 0.71 | 1554 |
| Laravel | 7.4 | 1084 | PHPStan | 2.3.0 | 15.72 | 1.48 | 328 |
| Laravel | 7.4 | 1084 | Mago | 1.53.0 | 0.35 | 0.34 | 933 |
| Laravel | 7.4 | 1084 | ECS | 13.3.3 | 5.03 | 5.39 | 60 |
| Laravel | 7.4 | 1084 | ECS --blink | 13.3.3 | 0.45 | 0.45 | 850 |
| Symfony | 8.4 | 12098 | PHPStan | 2.3.0 | 173.80 | 151.19 | 630 |
| Symfony | 8.4 | 12098 | Mago | 1.53.0 | 4.03 | 4.03 | 1967 |
| Symfony | 8.4 | 12098 | ECS | 13.3.3 | 102.54 | 50.71 | 159 |
| Symfony | 8.4 | 12098 | ECS --blink | 13.3.3 | 1.33 | 1.40 | 2089 |

Mago is ~30-45x faster than PHPStan. PHPStan's cache makes the small Laravel re-run near-instant (1.7s); on
Symfony's large graph it helps less (174s -> 151s), while Mago keeps no cache so its cold and hot
runs match. Mago trades memory for speed - it holds `vendor/` in memory, so peak RSS runs ~3-6x higher.

ECS runs the same PSR-12 rules through two engines. The Go binary (`--blink`) is ~10-80x faster than
the PHP engine (Symfony 102.5s -> 1.3s) and, like Mago, trades memory for speed - it loads sources
into memory, so peak RSS jumps while the PHP engine stays lean. ECS's PHP-engine cache mainly helps
on Symfony (102.5s -> 50.7s); on the small Laravel `src/` the parallel startup dominates, so hot and
cold roughly match. `--blink` keeps no cache, so its cold and hot runs match.

The PHP 7.4 rows use **Laravel 8.x** (the last line supporting PHP 7.4; current Laravel needs 8.3+).
PHPStan runs under `php7.4` and Mago targets 7.4. They are not directly comparable to the 8.4
rows - different Laravel version and a smaller `src/` (1084 vs 1707 files). Mago is a standalone Rust
binary, so the PHP runtime does not affect it. ECS `13.3.3` requires PHP 8.x to run, so its 7.4 rows
check the 7.4-era source with the checker itself running under `php8.4`; only the analyzed code is 7.4.

## Run

Needs `php8.4`, `composer`, `git`, `curl`, GNU `time`.

```bash
./setup.sh   # install tools, clone + composer-install both frameworks
./bench.sh   # benchmark -> results/results.md   (median of RUNS=3; set RUNS=1 for a quick pass)
```

`tools/` and `projects/` are gitignored and recreated by `setup.sh`.

## Versions

| Tool | Version | Released | Min PHP to run |
|------|---------|----------|----------------|
| [PHPStan](https://phpstan.org/) | 2.3.0 | 2026-10-06 | 7.4 (`php: ^7.4\|^8.0`) |
| [Mago](https://github.com/carthage-software/mago) | 1.53.0 | 2026-10-08 | none - standalone Rust binary |
| [ECS](https://github.com/easy-coding-standard/easy-coding-standard) | 13.3.3 | 2026-10-07 | 8.x (`--blink` Go binary is runtime-independent) |

Not a scientific benchmark: the tools run different checks and numbers are host-dependent.
