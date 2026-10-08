# need-for-speed

Speed comparison of PHP code-quality tools on real framework source:
static analysis with **[PHPStan](https://phpstan.org/)** (PHP) vs **[Mago](https://github.com/carthage-software/mago)** (Rust),
and coding-standard checks with **[ECS](https://github.com/easy-coding-standard/easy-coding-standard)**
in both engines - the PHP engine (`check`) and the bundled Go binary (`check --blink`) -
plus **[PHP-CS-Fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer)** (the fixer ECS wraps).
All run against Laravel and Symfony `src/`. Inspired by
[php-toolchain-benchmarks](https://github.com/carthage-software/php-toolchain-benchmarks), kept minimal.

## Results

PHP 8.4.26, all tools pinned to 24 threads/processes, median of 3 runs.
PHPStan at level 8; Mago `analyze` with strict toggles (Mago has no numeric levels); ECS and PHP-CS-Fixer at PER-CS.
**Cold** = fresh run; **Hot** = immediate re-run (PHPStan, ECS and PHP-CS-Fixer reuse a result cache; Mago and ECS `--blink` keep none).
PHPStan rows were measured on host `Linux 7.0.0-31-generic`; the Mago `1.53.0`, ECS and PHP-CS-Fixer rows
were measured on `Linux 7.0.0-38-generic`, so absolute numbers are not strictly host-matched across tools.

### On PHP 8.4

| Project | Files | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------:|------|---------|---------:|--------:|--------------:|
| Laravel | 1707 | PHPStan | 2.3.0 | 33.75 | 1.69 | 389 |
| Laravel | 1707 | Mago | 1.53.0 | **1.04** | **1.05** | 2228 |
| Laravel | 1707 | ECS | 13.3.3 | 10.82 | 11.77 | 68 |
| Laravel | 1707 | ECS --blink | 13.3.3 | 2.06 | 2.18 | 1437 |
| Laravel | 1707 | PHP-CS-Fixer | 3.95.27 | 15.89 | 13.55 | 75 |
| Symfony | 12098 | PHPStan | 2.3.0 | 173.80 | 151.19 | 630 |
| Symfony | 12098 | Mago | 1.53.0 | 4.03 | 4.03 | 1967 |
| Symfony | 12098 | ECS | 13.3.3 | 126.77 | 69.37 | 159 |
| Symfony | 12098 | ECS --blink | 13.3.3 | **3.53** | **3.41** | 2182 |
| Symfony | 12098 | PHP-CS-Fixer | 3.95.27 | 147.06 | 93.12 | 175 |

### On PHP 7.4 (Laravel 8.x)

| Project | Files | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------:|------|---------|---------:|--------:|--------------:|
| Laravel | 1084 | PHPStan | 2.3.0 | 15.72 | 1.48 | 328 |
| Laravel | 1084 | Mago | 1.53.0 | **0.35** | **0.34** | 933 |
| Laravel | 1084 | ECS | 13.3.3 | 6.35 | 7.21 | 61 |
| Laravel | 1084 | ECS --blink | 13.3.3 | 1.20 | 0.47 | 830 |
| Laravel | 1084 | PHP-CS-Fixer | 3.95.27 | 7.83 | 7.21 | 70 |

Mago is ~30-45x faster than PHPStan. PHPStan's cache makes the small Laravel re-run near-instant (1.7s); on
Symfony's large graph it helps less (174s -> 151s), while Mago keeps no cache so its cold and hot
runs match. Mago trades memory for speed - it holds `vendor/` in memory, so peak RSS runs ~3-6x higher.

ECS runs the same PER-CS rules through two engines. The Go binary (`--blink`) is ~5-35x faster than
the PHP engine (Symfony 126.8s -> 3.5s) and, like Mago, trades memory for speed - it loads sources
into memory, so peak RSS jumps while the PHP engine stays lean. ECS's PHP-engine cache mainly helps
on Symfony (126.8s -> 69.4s); on the small Laravel `src/` the parallel startup dominates, so hot and
cold roughly match. `--blink` keeps no cache, so its cold and hot runs match.

PHP-CS-Fixer is the fixer ECS wraps, so its PHP-engine numbers land in the same ballpark as ECS's
(Symfony 147s cold, Laravel ~16s). Its cache helps most on Symfony (147s -> 93s). On Symfony the config
also enables the 9 risky rules that Symfony's own `@php-cs-fixer-ignore` annotations reference - without
them PHP-CS-Fixer refuses to run; they are cheap and do not move the timing.

Note the coding-standard rows use PER-CS, which is broader than PSR-12 - so these numbers run higher
than an equivalent PSR-12 pass, and under PER-CS Mago edges out ECS `--blink` as the fastest tool on
the small Laravel `src/`.

The PHP 7.4 rows use **Laravel 8.x** (the last line supporting PHP 7.4; current Laravel needs 8.3+).
PHPStan runs under `php7.4` and Mago targets 7.4. They are not directly comparable to the 8.4
rows - different Laravel version and a smaller `src/` (1084 vs 1707 files). Mago is a standalone Rust
binary, so the PHP runtime does not affect it. ECS `13.3.3` requires PHP 8.x to run, so its 7.4 rows
check the 7.4-era source with the checker itself running under `php8.4`; only the analyzed code is 7.4.
PHP-CS-Fixer is the same: it supports PHP 7.4, but its `vendor/` here is installed under `php8.4`
(Composer locks the platform), so its 7.4 row also runs the checker under `php8.4`.

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
| [PHP-CS-Fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer) | 3.95.27 | 2026-09-22 | 7.4 (`php: ^7.4\|^8.0`) |

Not a scientific benchmark: the tools run different checks and numbers are host-dependent.
