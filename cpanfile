requires 'perl', '5.008001';

requires 'HTML::Template';
requires 'Class::Inspector';
requires 'Sub::Information';
requires 'File::Basename';
requires 'File::Path';
requires 'Getopt::Long';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

