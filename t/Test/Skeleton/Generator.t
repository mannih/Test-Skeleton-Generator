use Test::Most;

BEGIN {
    use_ok( 'Test::Skeleton::Generator' );
}

if ( $ARGV[ 0 ] ) {
    no strict 'refs';
    &{$ARGV[ 0 ]}();
    done_testing;
    exit 0;
}

test_analyze_t_file();
test__debug();
test_get_package_functions();
test_get_package_name();
test_new();
test_prepare_template();
test_prepare_test_file_path();
test_get_test();
test_get_updated_calls();
test_write_test_file();

done_testing;


sub get_object {
    return Test::Skeleton::Generator->new( @_ );
}

sub test_analyze_t_file {
    can_ok 'Test::Skeleton::Generator', 'analyze_t_file';
}

sub test__debug {
    can_ok 'Test::Skeleton::Generator', '_debug';
}

sub test_get_package_functions {
    can_ok 'Test::Skeleton::Generator', 'get_package_functions';
    my $obj = get_object(
        {
            package_file => 'lib/Test/Skeleton/Generator.pm',
            test_file    => '/tmp/foo.t',
        }
    );
    $obj->{ skip_private_methods } = 0;
    my $funs = $obj->get_package_functions( 'Test::Skeleton::Generator', {} );
    is $#$funs, 9, 'correct number of subs extracted';

    $obj->{ skip_private_methods } = 1;
    $funs = $obj->get_package_functions( 'Test::Skeleton::Generator', {} );
    is $#$funs, 8, 'correct number of subs extracted';
}

sub test_get_package_name {
    can_ok 'Test::Skeleton::Generator', 'get_package_name';
}

sub test_new {
    can_ok 'Test::Skeleton::Generator', 'new';
}

sub test_prepare_template {
    can_ok 'Test::Skeleton::Generator', 'prepare_template';
}

sub test_prepare_test_file_path {
    can_ok 'Test::Skeleton::Generator', 'prepare_test_file_path';
}

sub test_get_test {
    can_ok 'Test::Skeleton::Generator', 'get_test';
}

sub test_get_updated_calls {
    can_ok 'Test::Skeleton::Generator', 'get_updated_calls';
}

sub test_write_test_file {
    can_ok 'Test::Skeleton::Generator', 'write_test_file';
}

