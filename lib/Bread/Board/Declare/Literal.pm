package Bread::Board::Declare::Literal;
use Moose;
# ABSTRACT: subclass of Bread::Board::Literal for Bread::Board::Declare

=head1 DESCRIPTION

=cut

extends 'Bread::Board::Literal';
with 'Bread::Board::Declare::Role::Service';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
