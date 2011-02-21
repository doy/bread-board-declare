#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Moose;

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
        constructor_name => 'create',
    );
}

with_immutable {
    my $foo = Foo->new;
    isa_ok($foo->bar, 'Bar');
} 'Foo';

done_testing;
