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
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    ::like(::exception { extends 'Bar' },
           qr/^Cannot inherit from Bar because MooseX::Bread::Board classes must inherit from Bread::Board::Container/,
           "error when inheriting from a non-container");
}

done_testing;
