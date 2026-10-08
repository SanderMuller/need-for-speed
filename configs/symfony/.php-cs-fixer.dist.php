<?php

declare(strict_types=1);

// @PER-CS ruleset, same target as the ECS rows. 24 processes to match the
// thread count pinned for the other tools.
// Symfony's source carries @php-cs-fixer-ignore annotations for 9 rules outside
// @PER-CS; PHP-CS-Fixer hard-fails unless those rules are enabled, so they are
// added here (risky allowed). They are cheap and do not move the timing.
$finder = PhpCsFixer\Finder::create()->in(__DIR__ . '/src');

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setParallelConfig(new PhpCsFixer\Runner\Parallel\ParallelConfig(24))
    ->setRules([
        '@PER-CS' => true,
        'error_suppression' => true,
        'long_to_shorthand_operator' => true,
        'native_function_invocation' => true,
        'no_superfluous_phpdoc_tags' => true,
        'no_useless_concat_operator' => true,
        'protected_to_private' => true,
        'psr_autoloading' => true,
        'random_api_migration' => true,
        'static_lambda' => true,
    ])
    ->setFinder($finder);
