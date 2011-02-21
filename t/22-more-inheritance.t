#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Parent;
    use Moose;
    use MooseX::Bread::Board;

    has foo => (
        is    => 'ro',
        isa   => 'Str',
        value => 'parent',
    );

    has bar => (
        is    => 'ro',
        isa   => 'Str',
        block => sub {
            my $s = shift;
            return $s->param('foo') . ' ' . 'parent';
        },
        dependencies => ['foo'],
    );
}

{
    package Child1;
    use Moose;
    use MooseX::Bread::Board;

    extends 'Parent';

    has foo => (
        is    => 'ro',
        isa   => 'Str',
        value => 'child',
    );
}

{
    package Child2;
    use Moose;
    use MooseX::Bread::Board;

    extends 'Parent';

    has bar => (
        is    => 'ro',
        isa   => 'Str',
        block => sub {
            my $s = shift;
            return $s->param('foo') . ' ' . 'child';
        },
        dependencies => ['foo'],
    );
}

{
    package Child3;
    use Moose;
    use MooseX::Bread::Board;

    extends 'Child1';

    has bar => (
        is    => 'ro',
        isa   => 'Str',
        block => sub {
            my $s = shift;
            return $s->param('foo') . ' ' . 'child';
        },
        dependencies => ['foo'],
    );
}

{
    my $obj = Parent->new;
    is($obj->foo, 'parent');
    is($obj->bar, 'parent parent');
}

{
    my $obj = Child1->new;
    is($obj->foo, 'child');
    is($obj->bar, 'child parent');
}

{
    my $obj = Child2->new;
    is($obj->foo, 'parent');
    is($obj->bar, 'parent child');
}

{
    my $obj = Child3->new;
    is($obj->foo, 'child');
    is($obj->bar, 'child child');
}

done_testing;
