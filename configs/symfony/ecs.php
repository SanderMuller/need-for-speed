<?php

declare(strict_types=1);

use Symplify\EasyCodingStandard\Config\ECSConfig;

// Same PER-CS workload for both engines: `ecs check` (PHP) and `--blink` (Go).
// 24 processes to match the thread count pinned for PHPStan and Mago.
return ECSConfig::configure()
    ->withPaths([__DIR__ . '/src'])
    ->withParallel(maxNumberOfProcess: 24)
    ->withPreparedSets(perCs: true);
