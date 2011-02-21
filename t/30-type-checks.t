#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Test::Moose;

{
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    has foo => (
        is    => 'ro',
        isa   => 'Ref',
        value => 'FOO',
    );
}

with_immutable {
    my $foo = Foo->new;
    like(exception { $foo->foo },
        qr/^Attribute \(foo\) does not pass the type constraint because: Validation failed for 'Ref' with value FOO/,
         "error when service returns invalid value");
} 'Foo';

done_testing;
