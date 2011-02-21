#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

{
    package Role1;
    use Moose::Role;
    use MooseX::Bread::Board;

    has role1 => (
        (Moose->VERSION < 1.9900
            ? (traits => ['Service'])
            : ()),
        is     => 'ro',
        isa    => 'Str',
        value  => 'ROLE1',
    );
}

{
    package Parent;
    use Moose;
    use MooseX::Bread::Board;

    with 'Role1';

    has foo => (
        is    => 'ro',
        isa   => 'Str',
        value => 'FOO',
    );

    has bar => (
        is    => 'ro',
        isa   => 'Str',
        block => sub {
            my $s = shift;
            return $s->param('foo') . 'BAR' . $s->param('role1');
        },
        dependencies => ['foo', 'role1'],
    );
}

{
    package Role2;
    use Moose::Role;
    use MooseX::Bread::Board;

    has role2 => (
        (Moose->VERSION < 1.9900
            ? (traits => ['Service'])
            : ()),
        is     => 'ro',
        isa    => 'Str',
        value  => 'ROLE2',
    );
}

{
    package Child;
    use Moose;
    use MooseX::Bread::Board;

    extends 'Parent';
    with 'Role2';

    has baz => (
        is    => 'ro',
        isa   => 'Str',
        value => 'BAZ',
    );

    has quux => (
        is    => 'ro',
        isa   => 'Str',
        block => sub {
            my $s = shift;
            return $s->param('foo')
                 . $s->param('bar')
                 . $s->param('baz')
                 . $s->param('role1')
                 . $s->param('role2')
                 . 'QUUX';
        },
        dependencies => ['foo', 'bar', 'baz', 'role1', 'role2'],
    );
}

{
    my $parent = Parent->new;
    isa_ok($parent, 'Bread::Board::Container');
    is($parent->role1, 'ROLE1');
    is($parent->foo, 'FOO');
    is($parent->bar, 'FOOBARROLE1');
}

{
    my $parent = Parent->new(role1 => '1ELOR', foo => 'OOF', bar => 'RAB');
    isa_ok($parent, 'Bread::Board::Container');
    is($parent->role1, '1ELOR');
    is($parent->foo, 'OOF');
    is($parent->bar, 'RAB');
}

{
    my $parent = Parent->new(role1 => '1ELOR', foo => 'OOF');
    isa_ok($parent, 'Bread::Board::Container');
    is($parent->role1, '1ELOR');
    is($parent->foo, 'OOF');
    is($parent->bar, 'OOFBAR1ELOR');
}

{
    my $child = Child->new;
    is($child->role1, 'ROLE1');
    is($child->foo, 'FOO');
    is($child->bar, 'FOOBARROLE1');
    is($child->role2, 'ROLE2');
    is($child->baz, 'BAZ');
    is($child->quux, 'FOOFOOBARROLE1BAZROLE1ROLE2QUUX');
}

{
    my $child = Child->new(
        role1 => '1ELOR',
        foo   => 'OOF',
        bar   => 'RAB',
        role2 => '2ELOR',
        baz   => 'ZAB',
        quux  => 'XUUQ',
    );
    is($child->role1, '1ELOR');
    is($child->foo, 'OOF');
    is($child->bar, 'RAB');
    is($child->role2, '2ELOR');
    is($child->baz, 'ZAB');
    is($child->quux, 'XUUQ');
}

{
    my $child = Child->new(
        role1 => '1ELOR',
        foo   => 'OOF',
        role2 => '2ELOR',
        baz   => 'ZAB',
    );
    is($child->role1, '1ELOR');
    is($child->foo, 'OOF');
    is($child->bar, 'OOFBAR1ELOR');
    is($child->role2, '2ELOR');
    is($child->baz, 'ZAB');
    is($child->quux, 'OOFOOFBAR1ELORZAB1ELOR2ELORQUUX');
}

done_testing;
