# Results

- Host: `Linux 7.0.0-31-generic`, PHP `8.4.26`
- PHPStan `2.3.0` (level 8), Mago `1.51.2` (analyze, strict toggles)
- Both pinned to 24 threads/processes. Runs per cell: 3 (median). Time in seconds, peak memory in MB.

| Project | Files (src) | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------|---------:|--------:|--------------:|
| laravel | 1707 | PHPStan | 2.3.0 | 33.75 | 1.69 | 389 |
| laravel | 1707 | Mago | 1.51.2 | 1.80 | 1.79 | 2102 |
| symfony | 12098 | PHPStan | 2.3.0 | 173.80 | 151.19 | 630 |
| symfony | 12098 | Mago | 1.51.2 | 17.98 | 10.54 | 1981 |

## Older PHP: Laravel 8.x on PHP 7.4

PHPStan runs under `php7.4`; Mago targets PHP 7.4. Median of 3 runs, 24 threads.

| Project | Files (src) | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------|---------:|--------:|--------------:|
| laravel8 | 1084 | PHPStan | 2.3.0 | 15.72 | 1.48 | 328 |
| laravel8 | 1084 | Mago | 1.51.2 | 0.98 | 1.30 | 898 |
