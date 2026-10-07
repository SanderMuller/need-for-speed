# Results

- Host: `Linux 7.0.0-31-generic`, PHP `8.4.26`
- PHPStan `2.3.0` (level 2), Mago `1.51.2` (analyze)
- Runs per cell: 1 (median reported). Time in seconds, peak memory in MB.

| Project | Files (src) | Tool | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------:|--------:|--------------:|
| laravel | 1707 | PHPStan | 32.26 | 1.40 | 439 |
| laravel | 1707 | Mago | 2.15 | 1.83 | 2099 |
| symfony | 12098 | PHPStan | 149.89 | 126.00 | 663 |
| symfony | 12098 | Mago | 10.68 | 10.14 | 1942 |
