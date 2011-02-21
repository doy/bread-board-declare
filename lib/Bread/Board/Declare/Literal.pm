package Bread::Board::Declare::Literal;
use Moose;

extends 'Bread::Board::Literal';
with 'Bread::Board::Declare::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
