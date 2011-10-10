#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package SubContainer;
    use Moose;
    use Bread::Board::Declare;

    has foo_sub => (
        is    => 'ro',
        isa   => 'Str',
        value => 'FOOSUB',
    );
}

{
    package Container;
    use Moose;
    use Bread::Board::Declare;

    has subcontainer => (
        traits => ['Container'],
        is     => 'ro',
        isa    => 'SubContainer',
    );
}

{
    my $c = Container->new;
    is($c->resolve(service => 'subcontainer/foo_sub'), 'FOOSUB');
    is($c->subcontainer->foo_sub, 'FOOSUB');
}

{
    my $c = Container->new(subcontainer => SubContainer->new(foo_sub => 'SUBFOO'));
    is($c->resolve(service => 'subcontainer/foo_sub'), 'SUBFOO');
    is($c->subcontainer->foo_sub, 'SUBFOO');
}

done_testing;
