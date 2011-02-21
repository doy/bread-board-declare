#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

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

{
    my $foo = Foo->new;
    like(exception { $foo->foo },
        qr/^Attribute \(foo\) does not pass the type constraint because: Validation failed for 'Ref' with value FOO/,
         "error when service returns invalid value");
}

done_testing;
