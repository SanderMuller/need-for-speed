# need-for-speed

Simple speed comparison of two PHP static analyzers, **[PHPStan](https://phpstan.org/)** (PHP)
and **[Mago](https://github.com/carthage-software/mago)** (Rust), each analyzing the source of two
real frameworks: **Laravel** and **Symfony**.

Inspired by [carthage-software/php-toolchain-benchmarks](https://github.com/carthage-software/php-toolchain-benchmarks),
kept deliberately small: two tools, two projects, one metric table.

## What it measures

Both tools run their static analysis over the framework's `src/` directory:

- **Cold** - fresh run, PHPStan result cache wiped first.
- **Hot** - immediate re-run. PHPStan reuses its result cache; Mago keeps no result cache, so its
  hot and cold numbers are expected to be close.
- **Peak memory** - max RSS across the run (GNU `time -v`).

## Results

- Host: `Linux 7.0.0-31-generic`, PHP `8.4.26`
- PHPStan `2.3.0` (level 2), Mago `1.51.2` (`analyze`)
- 1 run per cell. Time in seconds, peak memory in MB.

| Project | Files (src) | Tool | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------:|--------:|--------------:|
| Laravel | 1707 | PHPStan | 32.26 | 1.40 | 439 |
| Laravel | 1707 | Mago | 2.15 | 1.83 | 2099 |
| Symfony | 12098 | PHPStan | 149.89 | 126.00 | 663 |
| Symfony | 12098 | Mago | 10.68 | 10.14 | 1942 |

**Takeaway:** cold, Mago is ~15x faster on Laravel and ~14x on Symfony. PHPStan's result cache
makes its hot Laravel run very fast (1.4s), but on Symfony the cache helps less (126s). Mago trades
memory for speed - it holds `vendor/` in memory, so peak RSS is ~3-5x PHPStan's.

Latest machine-generated table: [`results/results.md`](results/results.md).

## Caveats

This is a rough wall-clock comparison, not a scientific benchmark:

- The tools do **not** run the same checks. PHPStan runs at level 2; Mago uses its default
  `analyze` ruleset. They report different issues. This compares "time to analyze this codebase
  with a reasonable default config", not identical work.
- Mago loads `vendor/` as `includes` for symbol resolution, which inflates its peak memory.
- Single run per cell by default (`RUNS=1`) - set `RUNS=3` for medians on a quiet machine.
- Numbers depend heavily on the host (CPU cores, disk). Reproduce on your own machine.

## Reproduce

Requirements: `php` (8.4+), `composer`, `git`, `curl`, GNU `time`.

```bash
./setup.sh      # installs Mago + PHPStan into tools/, clones + composer-installs both frameworks
./bench.sh      # runs the benchmark, writes results/results.md
RUNS=3 ./bench.sh   # 3 runs per cell, report medians
```

## Layout

```
setup.sh            install tools, clone + prepare projects
bench.sh            run the benchmark, emit results/results.md
configs/<proj>/     phpstan.neon + mago.toml copied into each project
tools/              Mago binary + phpstan.phar        (gitignored)
projects/           cloned frameworks + vendor/        (gitignored)
results/results.md  latest results
```

## Versions

| Tool | Version | Released | Min PHP to run the tool |
|------|---------|----------|-------------------------|
| [PHPStan](https://phpstan.org/) | 2.3.0 | 2026-10-06 | PHP 7.4 (`php: ^7.4\|^8.0`) |
| [Mago](https://github.com/carthage-software/mago) | 1.51.2 | 2026-10-03 | none - standalone Rust binary, no PHP runtime needed |

PHPStan was run at level 2; Mago with its default `analyze` ruleset.
