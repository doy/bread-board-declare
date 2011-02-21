#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    package Foo;
    use Moose;
    use MooseX::Bread::Board;

    ::like(::exception {
        has foo => (
            is      => 'ro',
            isa     => 'Str',
            default => 'OOF',
            value   => 'FOO',
        );
    }, qr/default is not valid when Bread::Board service options are set/,
       "can't set a default when creating a service");

    ::like(::exception {
        has bar => (
            is      => 'ro',
            isa     => 'Str',
            default => sub { 'OOF' },
            value   => 'FOO',
        );
    }, qr/default is not valid when Bread::Board service options are set/,
       "can't set a default when creating a service");

    ::like(::exception {
        has baz => (
            is      => 'ro',
            isa     => 'Str',
            lazy    => 1,
            default => 'OOF',
            value   => 'FOO',
        );
    }, qr/default is not valid when Bread::Board service options are set/,
       "can't set a default when creating a service");

    ::like(::exception {
        has quux => (
            is      => 'ro',
            isa     => 'Str',
            lazy    => 1,
            default => sub { 'OOF' },
            value   => 'FOO',
        );
    }, qr/default is not valid when Bread::Board service options are set/,
       "can't set a default when creating a service");
}

done_testing;
