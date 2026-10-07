# need-for-speed

Speed comparison of two PHP static analyzers on real framework source:
**[PHPStan](https://phpstan.org/)** (PHP) vs **[Mago](https://github.com/carthage-software/mago)** (Rust),
analyzing Laravel and Symfony `src/`. Inspired by
[php-toolchain-benchmarks](https://github.com/carthage-software/php-toolchain-benchmarks), kept minimal.

## Results

Host `Linux 7.0.0-31-generic`, PHP 8.4.26, both tools pinned to 24 threads, 1 run per cell.
PHPStan at level 8; Mago `analyze` with strict toggles (Mago has no numeric levels).
**Cold** = fresh run; **Hot** = immediate re-run (PHPStan reuses its result cache, Mago keeps none).

| Project | Files | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------:|------|---------|---------:|--------:|--------------:|
| Laravel | 1707 | PHPStan | 2.3.0 | 37.00 | 1.84 | 389 |
| Laravel | 1707 | Mago | 1.51.2 | 2.02 | 1.81 | 2102 |
| Symfony | 12098 | PHPStan | 2.3.0 | 172.25 | 216.04 | 630 |
| Symfony | 12098 | Mago | 1.51.2 | 11.39 | 10.02 | 1981 |

Mago is ~15-18x faster cold. PHPStan's cache makes the small Laravel re-run near-instant (1.8s),
but on Symfony's large graph it gives no gain (hot ≈ cold). Mago trades memory for speed - it holds
`vendor/` in memory, so peak RSS runs ~3-5x higher.

## Run

Needs `php8.4`, `composer`, `git`, `curl`, GNU `time`.

```bash
./setup.sh   # install tools, clone + composer-install both frameworks
./bench.sh   # benchmark -> results/results.md   (RUNS=3 for medians)
```

`tools/` and `projects/` are gitignored and recreated by `setup.sh`.

## Versions

| Tool | Version | Released | Min PHP to run |
|------|---------|----------|----------------|
| [PHPStan](https://phpstan.org/) | 2.3.0 | 2026-10-06 | 7.4 (`php: ^7.4\|^8.0`) |
| [Mago](https://github.com/carthage-software/mago) | 1.51.2 | 2026-10-03 | none - standalone Rust binary |

Not a scientific benchmark: the tools run different checks and numbers are host-dependent.
