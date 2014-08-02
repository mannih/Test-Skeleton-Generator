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


sub new {
    my $class   = shift;
    my $options = shift;

    my $self = bless {
        package_file         => '',
        test_file            => '',
        skip_private_methods => 0,
    }, $class;

    foreach my $key ( keys %$self ) {
        $self->{ $key } = $options->{ $key } if exists $options->{ $key };
    };

    return $self;
}

sub main {
    my $self = shift;

    debug( "package_file: $self->{ package_file } - test_file: $self->{ test_file }" );

    my $existing_test_subs = analyze_t_file( $self->{ test_file } );
    my $package            = get_package_name( $self->{ package_file } );
    debug( "Trying to use package $package." );
    my @functions = get_package_functions( $package, $existing_test_subs );
    prepare_test_file_path( $self->{ test_file } ) unless -e $self->{ test_file };

    my $tmpl = prepare_template( $package, \@functions );
    $tmpl->param( update => %$existing_test_subs ? 1 : 0 );

    if ( -e $self->{ test_file } ) {
        update_test_file( $self->{ test_file }, $tmpl, \@functions );
    }
    else {
        make_test_file( $self->{ test_file }, $tmpl->output );
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

    make_test_file( $t_content );
}

sub make_test_file {
    my $self    = shift;
    my $content = shift;

    open my $fh, '>', $self->{ test_file };
    print $fh $content;
}

sub prepare_template {
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
    debug( "dirname of $self->{ test_file } is $dir." );

    unless ( -d $dir ) {
        debug( "Making path $dir" );
        make_path( $dir );
    }
}

sub get_package_functions {
    my $package            = shift;
    my $existing_test_subs = shift;

    eval "use $package";
    if ( my $err = $@ ) {
        die $err;
    }

    my $functions = Class::Inspector->function_refs( $package );
    my @functions;
    foreach my $function ( @$functions ) {
        my $info = inspect( $function );
        my $name = $info->name;
        next if $name =~ /^[[:upper:]_]+$/;
        next if $info->package ne $package;

        if ( ! $existing_test_subs->{ "test_$name" } ) {
            push @functions, { function => $name };
        }
    }

    return @functions;
}

sub get_package_name {
    my $self = shift;

    my $package = $self->{ package_file };
    if ( $package =~ m#/# ) {
        debug( 'Package provided by file path' );
        open my $fh, '<', $self->{ package_file } or exit_helpfully();
        while ( my $ln = <$fh> ) {
            if ( $ln =~ m/^package (.+);\s*$/ ) {
                $package = $1;
                last;
            }
        }
    }
    debug( 'package name is ' . $package );

    return $package;
}

sub debug {
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

sub exit_helpfully {
    print "Bitte auf der Kommandozeile den Pfad zur zu testenden Modul-Datei\n";
    print "und den Pfad zur Test-Datei angeben\n";
    exit 1;
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


__END__

=encoding utf-8

=head1 NAME

Test::Skeleton::Generator - It's new $module

=head1 SYNOPSIS

    use Test::Skeleton::Generator;

=head1 DESCRIPTION

Test::Skeleton::Generator is ...

=head1 LICENSE

Copyright (C) Manni Heumann.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Manni Heumann E<lt>github@lxxi.orgE<gt>

=cut

