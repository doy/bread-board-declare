package Bread::Board::Declare::ConstructorInjection;
use Moose;

extends 'Bread::Board::ConstructorInjection';
with 'Bread::Board::Declare::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
