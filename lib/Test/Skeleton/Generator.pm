package Test::Skeleton::Generator;

use 5.001000;
use strict;
use warnings;
use autodie ':all';

our $VERSION = "0.01";

use HTML::Template;
use Class::Inspector;
use Sub::Information;
use File::Basename;
use File::Path qw/ make_path /;

my $DEBUG = 0;

=head1 NAME

Test::Skeleton::Generator - 

=head1 SYNOPSIS

    perl -MTest::Skeleton::Generator -e 'Test::Skeleton::Generator->new->make'

=head1 DESCRIPTION

Test::Skeleton::Generator is ...

=head1 LICENSE

Copyright (C) Manni Heumann.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Manni Heumann E<lt>github@lxxi.orgE<gt>

=cut


sub new {
    my $class   = shift;
    my $options = shift;

    my $self = bless {
        package_file         => '',
        test_file            => '',
        skip_private_methods => 0,
    }, $class;

    if ( $options ) {
        foreach my $key ( keys %$self ) {
            $self->{ $key } = $options->{ $key } if exists $options->{ $key };
        };
        return $self;
    }
    elsif ( @ARGV == 2 ) {
        $self->{ package_file } = $ARGV[ 0 ];
        $self->{ test_file    } = $ARGV[ 1 ];
        $self->make;
    }
    else {
        die 'You need to provide the name of the package and the path to the test file.';
    }
}

sub make {
    my $self = shift;

    my $existing_test_subs = $self->analyze_t_file;
    my $package            = $self->get_package_name;
    my $functions          = $self->get_package_functions( $package, $existing_test_subs );

    $self->prepare_test_file_path unless -e $self->{ test_file };

    my $tmpl = $self->prepare_template( $package, $functions );
    $tmpl->param( update => %$existing_test_subs ? 1 : 0 );

    if ( -e $self->{ test_file } ) {
        $self->update_test_file( $tmpl, $functions );
    }
    else {
        $self->make_test_file( $tmpl->output );
    }
}

sub update_test_file {
    my $self      = shift;
    my $tmpl      = shift;
    my $functions = shift;

    local $/;
    open my $fh, '<', $self->{ test_file };
    my $t_content = <$fh>;
    close $fh;

    my $missing_calls = '';
    foreach my $fun ( @$functions ) {
        $missing_calls .= sprintf "test_%s();\n", $fun->{ function };
    }

    $t_content =~ s/^done_testing/$missing_calls\ndone_testing/ms;
    $t_content .= $tmpl->output;

    $self->make_test_file( $t_content );
}

sub make_test_file {
    my $self    = shift;
    my $content = shift;

    open my $fh, '>', $self->{ test_file };
    print $fh $content;
    close $fh;
}

sub prepare_template {
    my $self      = shift;
    my $package   = shift;
    my $functions = shift;

    my $tmpl = HTML::Template->new(
                    filehandle        => \*DATA,
                    global_vars       => 1,
                    die_on_bad_params => 0,
                    loop_context_vars => 1,
    );
    $tmpl->param( package   => $package );
    $tmpl->param( functions => $functions );

    return $tmpl;
}

sub prepare_test_file_path {
    my $self = shift;

    my $dir = dirname( $self->{ test_file } );
    _debug( "dirname of $self->{ test_file } is $dir." );

    unless ( -d $dir ) {
        _debug( "Making path $dir" );
        make_path( $dir );
    }
}

sub get_package_functions {
    my $self               = shift;
    my $package            = shift;
    my $existing_test_subs = shift;

    _debug( "Trying to use package $package." );
    eval "use $package";
    if ( my $err = $@ ) {
        die "could not 'use' package $package: $err";
    }

    my $wanted_subs = [];
    my $found_subs  = Class::Inspector->function_refs( $package );
    foreach my $function ( @$found_subs ) {
        my $info = inspect( $function );
        my $name = $info->name;
        next if $name =~ m/^[[:upper:]_]+$/;
        next if $name =~ m/^_/ && $self->{ skip_private_methods };
        next if $info->package ne $package;

        if ( ! $existing_test_subs->{ "test_$name" } ) {
            push @$wanted_subs, { function => $name };
        }
    }

    return $wanted_subs;
}

sub get_package_name {
    my $self = shift;

    my $package = $self->{ package_file };
    if ( $package =~ m#/# ) {
        _debug( 'Package provided by file path' );
        open my $fh, '<', $self->{ package_file };
        while ( my $ln = <$fh> ) {
            if ( $ln =~ m/^package (.+);\s*$/ ) {
                $package = $1;
                last;
            }
        }
    }
    _debug( 'package name is ' . $package );

    return $package;
}

sub _debug {
    return unless $DEBUG;
    my @msgs = @_;
    foreach ( @msgs ) {
        print $_, "\n";
    }
}

sub analyze_t_file {
    my $self = shift;

    if ( ! -e $self->{ test_file } ) {
        return {};
    }

    open my $fh, '<', $self->{ test_file };
    my $subs = {};
    while ( my $ln = <$fh> ) {
        if ( $ln =~ m/\bsub\s+(\w+)/ ) {
            $subs->{ $1 } = 1;
        }
    }

    return $subs;
}

1;

__DATA__
<tmpl_unless update>use Test::Most;
BEGIN {
    use_ok( '<tmpl_var package>' );
}

if ( $ARGV[ 0 ] ) {
    no strict 'refs';
    &{$ARGV[ 0 ]}();
    done_testing;
    exit 0;
}


<tmpl_loop functions>test_<tmpl_var function>();
</tmpl_loop>
done_testing;


sub get_object {
    return <tmpl_var package>->new;
}
</tmpl_unless><tmpl_loop functions>
sub test_<tmpl_var function> {
    can_ok '<tmpl_var package>', '<tmpl_var function>';
    my $obj = get_object;
}
</tmpl_loop>
