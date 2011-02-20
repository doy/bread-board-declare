package MooseX::Bread::Board::BlockInjection;
use Moose;

extends 'Bread::Board::BlockInjection';
with 'MooseX::Bread::Board::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
