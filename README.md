# need-for-speed

Speed comparison of two PHP static analyzers on real framework source:
**[PHPStan](https://phpstan.org/)** (PHP) vs **[Mago](https://github.com/carthage-software/mago)** (Rust),
analyzing Laravel and Symfony `src/`. Inspired by
[php-toolchain-benchmarks](https://github.com/carthage-software/php-toolchain-benchmarks), kept minimal.

## Results

Host `Linux 7.0.0-31-generic`, PHP 8.4.26, both tools pinned to 24 threads, median of 3 runs.
PHPStan at level 8; Mago `analyze` with strict toggles (Mago has no numeric levels).
**Cold** = fresh run; **Hot** = immediate re-run (PHPStan reuses its result cache, Mago keeps none).

| Project | PHP | Files | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|----:|------:|------|---------|---------:|--------:|--------------:|
| Laravel | 8.4 | 1707 | PHPStan | 2.3.0 | 33.75 | 1.69 | 389 |
| Laravel | 8.4 | 1707 | Mago | 1.51.2 | 1.80 | 1.79 | 2102 |
| Laravel | 7.4 | 1084 | PHPStan | 2.3.0 | 15.72 | 1.48 | 328 |
| Laravel | 7.4 | 1084 | Mago | 1.51.2 | 0.98 | 1.30 | 898 |
| Symfony | 8.4 | 12098 | PHPStan | 2.3.0 | 173.80 | 151.19 | 630 |
| Symfony | 8.4 | 12098 | Mago | 1.51.2 | 17.98 | 10.54 | 1981 |

Mago is ~10-19x faster. PHPStan's cache makes the small Laravel re-run near-instant (1.7s); on
Symfony's large graph it helps less (174s -> 151s). Mago trades memory for speed - it holds
`vendor/` in memory, so peak RSS runs ~3-5x higher.

The PHP 7.4 rows use **Laravel 8.x** (the last line supporting PHP 7.4; current Laravel needs 8.3+),
with PHPStan run under `php7.4` and Mago targeting 7.4. They are not directly comparable to the 8.4
rows - different Laravel version and a smaller `src/` (1084 vs 1707 files). Mago is a standalone Rust
binary, so the PHP runtime does not affect it.

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
| [Mago](https://github.com/carthage-software/mago) | 1.51.2 | 2026-10-03 | none - standalone Rust binary |

Not a scientific benchmark: the tools run different checks and numbers are host-dependent.
