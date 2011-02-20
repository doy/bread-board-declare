#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Baz;
    use Moose;

    has bar => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );
}

{
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    my $i = 0;
    has bar => (
        is    => 'ro',
        isa   => 'Str',
        block => sub { $i++ },
    );

    has baz => (
        is           => 'ro',
        isa          => 'Baz',
        class        => 'Baz',
        dependencies => ['bar'],
    );
}

{
    my $foo = Foo->new;
    my $baz = $foo->baz;
    is($baz->bar, '0', "deps resolved correctly");
    is($baz->bar, '0', "doesn't re-resolve, since Baz is a normal class");
    is($foo->baz->bar, '1', "re-resolves since the baz attr isn't a singleton");
}

done_testing;
