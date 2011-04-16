#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

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
        is    => 'ro',
        isa   => 'Foo',
        block => sub { Foo->new },
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

{
    my $c = My::Container->new;
    isa_ok($c->baz, 'Baz');
    isa_ok($c->baz->foo, 'Foo');
    isa_ok($c->baz->bar, 'Bar');
}

{
    package Baz2;
    use Moose;

    extends 'Baz';

    has thing => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );
}

{
    package My::Container2;
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

    has foo => (
        is  => 'ro',
        isa => 'Foo',
    );

    has bar => (
        is  => 'ro',
        isa => 'Bar',
    );

    has thing => (
        is    => 'ro',
        isa   => 'Str',
        value => 'THING',
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
    is($c->baz->thing, 'THING', "partial dependency specification works");
}

{
    package My::Container4;
    use Moose;
    use Bread::Board::Declare;

    has foo => (
        is  => 'ro',
        isa => 'Foo',
    );

    has other_foo => (
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

{
    like(
        exception { My::Container4->new },
        qr/^You have already declared a typemap for type Foo/,
        "correct error when inferring is ambiguous"
    );
}

{
    package Foo2;
    use Moose;

    extends 'Foo';

    has bar => (
        is       => 'ro',
        isa      => 'Bar',
        required => 1,
    );
}

{
    package My::Container5;
    use Moose;
    use Bread::Board::Declare;

    has foo => (
        is  => 'ro',
        isa => 'Foo2',
    );

    has other_foo => (
        is      => 'ro',
        isa     => 'Foo2',
        typemap => 0,
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

{
    my $c = My::Container5->new;
    isa_ok($c->baz, 'Baz');
    isa_ok($c->baz->foo, 'Foo');
    isa_ok($c->baz->bar, 'Bar');
    isa_ok($c->other_foo->bar, 'Bar');
}

done_testing;
