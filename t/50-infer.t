#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Foo;
    use Moose;
}

{
    package Bar;
    use Moose;
}

{
    package Baz;
    use Moose;

    has foo => (
        is       => 'ro',
        isa      => 'Foo',
        required => 1,
    );

    has bar => (
        is       => 'ro',
        isa      => 'Bar',
        required => 1,
    );
}

{
    package My::Container;
    use Moose;
    use Bread::Board::Declare;

    has foo => (
        is  => 'ro',
        isa => 'Foo',
    );

    has bar => (
        is  => 'ro',
        isa => 'Bar',
    );

    has baz => (
        is  => 'ro',
        isa => 'Baz',
    );
}

my $c = My::Container->new;
isa_ok($c->baz, 'Baz');
isa_ok($c->baz->foo, 'Foo');
isa_ok($c->baz->bar, 'Bar');

done_testing;
