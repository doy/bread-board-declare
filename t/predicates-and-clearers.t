#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Moose;
use Scalar::Util 'refaddr';

{
    package Bar;
    use Moose;
}

{
    package Foo;
    use Moose;
    use Bread::Board::Declare;

    has bar => (
        isa          => 'Bar',
		is           => 'ro',
        lifecycle    => 'Singleton',
		predicate    => 'has_bar',
		clearer      => 'clear_bar',
    );
}

with_immutable {
    my $foo = Foo->new;
    ok ! $foo->has_bar, 'does not have bar';
	isa_ok my $inst0 = $foo->bar, 'Bar';
	is refaddr( $inst0 ), refaddr( $foo->bar ), 'same instance';
    ok $foo->has_bar, 'has bar';
	$foo->clear_bar;
    ok ! $foo->has_bar, 'does not have bar';
	isnt refaddr( $inst0 ), refaddr( $foo->bar ), 'not the same instance';
    ok $foo->has_bar, 'has bar';
} 'Foo';

done_testing;
