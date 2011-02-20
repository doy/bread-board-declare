package MooseX::Bread::Board::Literal;
use Moose;

extends 'Bread::Board::Literal';
with 'MooseX::Bread::Board::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
