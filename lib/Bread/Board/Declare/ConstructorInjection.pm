package Bread::Board::Declare::ConstructorInjection;
use Moose;
# ABSTRACT: subclass of Bread::Board::ConstructorInjection for Bread::Board::Declare

=head1 DESCRIPTION

=cut

extends 'Bread::Board::ConstructorInjection';
with 'Bread::Board::Declare::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
