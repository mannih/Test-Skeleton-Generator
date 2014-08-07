# NAME

Test::Skeleton::Generator - Create a skeleton for a test file based on an existing module

# SYNOPSIS

simply

    perl -MTest::Skeleton::Generator -e 'Test::Skeleton::Generator->new' ./lib/Module.pm ./t/test.t

Or maybe:

    use Test::Skeleton::Generator;
    my $generator = Test::Skeleton::Generator->new( {
         package_file => './lib/Some/Module.pm',
         skip_private_methods => 1,
    } );
    my $test_file_content = $generator->get_test;

# DESCRIPTION

Test::Skeleton::Generator is supposed to be used from within your editor to quickly
generate skeletons/stubs for a test file that is supposed to test the module you
are currently working on.

So suppose you are working on the file ./lib/Foo/Bar.pm which hasn't got any tests
yet, you simply press a keyboard shortcut or click an icon (if you really have to)
and now your editor would simply call perl like in the SYNOPSIS to generate a .t file
in your ./t/ directory. You don't have to write the boiler-plate code yourself.

There are two ways to use this module:

The simplest way to use this module, is from the command line. Simply use it, call new,
and provide two command line arguments: the path to the module you want to test
and the path to the test file you'd like to create.

But if you find it useful, you can also use it from another script or module which
will give you more option and lets you handle the content of the future test file yourself.

# LICENSE

Copyright (C) Manni Heumann.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Manni Heumann <github@lxxi.org>
