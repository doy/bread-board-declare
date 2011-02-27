#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Bar;
    use Moose;

    has foo => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );
}

{
    package Foo;
    use Moose;
    use Bread::Board::Declare;

    has foo => (
        is    => 'ro',
        isa   => 'Str',
        value => 'FOO',
    );

    has bar => (
        is           => 'ro',
        isa          => 'Bar',
        dependencies => ['foo'],
    );
}

my $foo1 = Foo->new;
is($foo1->bar->foo, 'FOO');
my $foo2 = Foo->new(foo => 'BAR');
is($foo2->bar->foo, 'BAR');

done_testing;
