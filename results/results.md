# Results

- Host: `Linux 7.0.0-38-generic`, PHP `8.4.26`
- PHPStan `2.3.0` (level 8), Mago `1.53.0` (analyze, strict toggles)
- ECS `13.3.3` (PSR-12): PHP engine (`check`) and Go binary (`check --blink`)
- PHP-CS-Fixer `3.95.27` (@PSR12)
- All pinned to 24 threads/processes. Runs per cell: 3 (median). Time in seconds, peak memory in MB.

| Project | Files (src) | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------|---------:|--------:|--------------:|
| laravel | 1707 | PHPStan | 2.3.0 | 33.75 | 1.69 | 389 |
| laravel | 1707 | Mago | 1.53.0 | 1.04 | 1.05 | 2228 |
| laravel | 1707 | ECS | 13.3.3 | 9.03 | 9.17 | 68 |
| laravel | 1707 | ECS --blink | 13.3.3 | 0.78 | 0.71 | 1554 |
| laravel | 1707 | PHP-CS-Fixer | 3.95.27 | 9.90 | 8.94 | 75 |
| symfony | 12098 | PHPStan | 2.3.0 | 173.80 | 151.19 | 630 |
| symfony | 12098 | Mago | 1.53.0 | 4.03 | 4.03 | 1967 |
| symfony | 12098 | ECS | 13.3.3 | 102.54 | 50.71 | 159 |
| symfony | 12098 | ECS --blink | 13.3.3 | 1.33 | 1.40 | 2089 |
| symfony | 12098 | PHP-CS-Fixer | 3.95.27 | 84.29 | 23.83 | 172 |

## Older PHP: Laravel 8.x on PHP 7.4

PHPStan runs under `php7.4`; Mago targets PHP 7.4. ECS `13.3.3` and PHP-CS-Fixer run under `php8.4`
(their `vendor/` is platform-locked to the install PHP), checking the 7.4-era source; only the
analyzed code is 7.4. Median of 3 runs, 24 threads.

| Project | Files (src) | Tool | Version | Cold (s) | Hot (s) | Peak mem (MB) |
|---------|------------:|------|---------|---------:|--------:|--------------:|
| laravel8 | 1084 | PHPStan | 2.3.0 | 15.72 | 1.48 | 328 |
| laravel8 | 1084 | Mago | 1.53.0 | 0.35 | 0.34 | 933 |
| laravel8 | 1084 | ECS | 13.3.3 | 5.03 | 5.39 | 60 |
| laravel8 | 1084 | ECS --blink | 13.3.3 | 0.45 | 0.45 | 850 |
| laravel8 | 1084 | PHP-CS-Fixer | 3.95.27 | 6.11 | 5.02 | 70 |
