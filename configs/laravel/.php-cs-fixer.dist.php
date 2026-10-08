<?php

declare(strict_types=1);

// @PER-CS ruleset, same target as the ECS rows. 24 processes to match the
// thread count pinned for the other tools.
$finder = PhpCsFixer\Finder::create()->in(__DIR__ . '/src');

return (new PhpCsFixer\Config())
    ->setParallelConfig(new PhpCsFixer\Runner\Parallel\ParallelConfig(24))
    ->setRules(['@PER-CS' => true])
    ->setFinder($finder);
