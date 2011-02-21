#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Bar;

    sub create { bless {}, shift }
}

{
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    has bar => (
        is               => 'ro',
        isa              => 'Bar',
        class            => 'Bar',
        constructor_name => 'create',
    );
}

{
    my $foo = Foo->new;
    isa_ok($foo->bar, 'Bar');
}

done_testing;
