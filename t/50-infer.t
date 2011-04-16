#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    package Foo;
    use Moose;

    has data => (
        is      => 'ro',
        isa     => 'Str',
        default => 'FOO',
    );
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

    has thing => (
        is  => 'ro',
        isa => 'Str',
    );
}

{
    package My::Container;
    use Moose;
    use Bread::Board::Declare;

    has baz => (
        is  => 'ro',
        isa => 'Baz',
    );
}

{
    my $c = My::Container->new;
    isa_ok($c->baz, 'Baz');
    isa_ok($c->baz->foo, 'Foo');
    isa_ok($c->baz->bar, 'Bar');

    is($c->baz->thing, undef, "right thing");
    is($c->baz->foo->data, 'FOO', "right data");

    isa_ok($c->resolve(type => 'Baz'), 'Baz');
}

{
    package Baz2;
    use Moose;

    extends 'Baz';

    has '+thing' => (
        required => 1,
    );
}

{
    package My::Container2;
    use Moose;
    use Bread::Board::Declare;

    has baz => (
        is  => 'ro',
        isa => 'Baz2',
    );
}

{
    like(
        exception { My::Container2->new },
        qr/^Only class types, role types, or subtypes of Object can be inferred\. I don't know what to do with type \(Str\)/,
        "correct error when not everything can be inferred"
    );
}

{
    package My::Container3;
    use Moose;
    use Bread::Board::Declare;

    has thing => (
        is    => 'ro',
        isa   => 'Str',
        value => 'THING',
    );

    has foo => (
        is           => 'ro',
        isa          => 'Foo',
        dependencies => { data => 'thing' },
    );

    has baz => (
        is           => 'ro',
        isa          => 'Baz2',
        dependencies => ['thing'],
    );
}

{
    my $c = My::Container3->new;
    isa_ok($c->baz, 'Baz2');
    isa_ok($c->baz->foo, 'Foo');
    isa_ok($c->baz->bar, 'Bar');

    is(
        $c->fetch('baz')->get_dependency('foo')->service,
        $c->fetch('foo'),
        "inferred the right dependency"
    );

    is($c->baz->foo->data, 'THING',
       "inference finds services in the container");
    is($c->baz->thing, 'THING', "partial dependency specification works");
}

{
    package Quux;
    use Moose;

    has baz => (
        is       => 'ro',
        isa      => 'Baz',
        required => 1,
    );

    has foo => (
        is  => 'ro',
        isa => 'Foo',
    );
}

{
    package My::Container4;
    use Moose;
    use Bread::Board::Declare;

    has data => (
        is    => 'ro',
        isa   => 'Str',
        value => 'DATA',
    );

    has quux => (
        is  => 'ro',
        isa => 'Quux',
    );

    has foo => (
        is           => 'ro',
        isa          => 'Foo',
        dependencies => ['data'],
    );

    has quux2 => (
        is           => 'ro',
        isa          => 'Quux',
        dependencies => ['foo'],
    );
}

{
    my $c = My::Container4->new;
    isa_ok($c->quux, 'Quux');
    isa_ok($c->quux->baz, 'Baz');
    isa_ok($c->quux->baz->foo, 'Foo');
    isa_ok($c->quux->baz->bar, 'Bar');

    is($c->quux->foo, undef, "non-required attrs are not inferred");
    is($c->quux2->foo->data, 'DATA', "but can be explicitly specified");
}

{
    package State;
    use Moose;

    has counter => (
        traits  => ['Counter'],
        is      => 'rw',
        isa     => 'Int',
        handles => { inc => 'inc' },
        default => 0,
    );
}

{
    package Controller;
    use Moose;

    has counter => (
        is       => 'ro',
        isa      => 'State',
        required => 1,
        handles  => { inc => 'inc', counter_val => 'counter' },
    );
}

{
    package App;
    use Moose;
    use Bread::Board::Declare;

    has counter => (
        is        => 'ro',
        isa       => 'State',
        lifecycle => 'Singleton',
    );

    has controller => (
        is  => 'ro',
        isa => 'Controller',
    );
}

{
    my $c = App->new;
    is(
        $c->fetch('controller')->get_dependency('counter')->service,
        $c->fetch('counter'),
        "inferred the right dependency"
    );
    $c->controller->inc;
    $c->controller->inc;
    is($c->controller->counter_val, 2, "state persisted as a singleton");
}

done_testing;
