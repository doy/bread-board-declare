#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    package Bar;
    use Moose;
}

{
    package Baz;
    use Moose;
    use MooseX::Bread::Board;
}

{
    package Quux;
    use Moose;
    use MooseX::Bread::Board;
}

{
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    ::like(::exception { extends 'Bar' },
           qr/^Cannot inherit from Bar because MooseX::Bread::Board classes must inherit from Bread::Board::Container/,
           "error when inheriting from a non-container");
    ::like(::exception { extends 'Baz', 'Quux' },
           qr/^Multiple inheritance is not supported for MooseX::Bread::Board classes/,
           "error when inheriting from multiple containers");
}

done_testing;
