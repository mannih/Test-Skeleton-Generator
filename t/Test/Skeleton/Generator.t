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
test_debug();
test_exit_helpfully();
test_get_package_functions();
test_get_package_name();
test_main();
test_make_test_file();
test_new();
test_prepare_template();
test_prepare_test_file_path();
test_update_test_file();

done_testing;


sub get_object {
    return Test::Skeleton::Generator->new;
}

sub test_analyze_t_file {
    can_ok 'Test::Skeleton::Generator', 'analyze_t_file';
    my $obj = get_object;
}

sub test_debug {
    can_ok 'Test::Skeleton::Generator', 'debug';
    my $obj = get_object;
}

sub test_exit_helpfully {
    can_ok 'Test::Skeleton::Generator', 'exit_helpfully';
    my $obj = get_object;
}

sub test_get_package_functions {
    can_ok 'Test::Skeleton::Generator', 'get_package_functions';
    my $obj = get_object;
}

sub test_get_package_name {
    can_ok 'Test::Skeleton::Generator', 'get_package_name';
    my $obj = get_object;
}

sub test_main {
    can_ok 'Test::Skeleton::Generator', 'main';
    my $obj = get_object;
}

sub test_make_test_file {
    can_ok 'Test::Skeleton::Generator', 'make_test_file';
    my $obj = get_object;
}

sub test_new {
    can_ok 'Test::Skeleton::Generator', 'new';
    my $obj = get_object;
}

sub test_prepare_template {
    can_ok 'Test::Skeleton::Generator', 'prepare_template';
    my $obj = get_object;
}

sub test_prepare_test_file_path {
    can_ok 'Test::Skeleton::Generator', 'prepare_test_file_path';
    my $obj = get_object;
}

sub test_update_test_file {
    can_ok 'Test::Skeleton::Generator', 'update_test_file';
    my $obj = get_object;
}

