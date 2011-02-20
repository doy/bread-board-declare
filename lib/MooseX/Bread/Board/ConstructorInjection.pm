package MooseX::Bread::Board::ConstructorInjection;
use Moose;

extends 'Bread::Board::ConstructorInjection';
with 'MooseX::Bread::Board::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
