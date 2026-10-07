# Results

- Host: `Linux 7.0.0-31-generic`, PHP `8.4.26`
- PHPStan `2.3.0` (level 8), Mago `1.51.2` (analyze, strict toggles)
- Both pinned to 24 threads/processes. Runs per cell: 1 (median). Time in seconds, peak memory in MB.

| Project | Files (src) | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------|---------:|--------:|--------------:|
| laravel | 1707 | PHPStan | 2.3.0 | 37.00 | 1.84 | 389 |
| laravel | 1707 | Mago | 1.51.2 | 2.02 | 1.81 | 2102 |
| symfony | 12098 | PHPStan | 2.3.0 | 172.25 | 216.04 | 630 |
| symfony | 12098 | Mago | 1.51.2 | 11.39 | 10.02 | 1981 |
