package Bread::Board::Declare::Meta::Role::Class;
use Moose::Role;
# ABSTRACT: class metarole for Bread::Board::Declare

use Bread::Board::Service;
use List::MoreUtils qw(any);

=head1 DESCRIPTION

=cut

=method get_all_services

=cut

sub get_all_services {
    my $self = shift;
    return map { $_->associated_service }
           grep { $_->has_associated_service }
           grep { Moose::Util::does_role($_, 'Bread::Board::Declare::Meta::Role::Attribute') }
           $self->get_all_attributes;
}

before superclasses => sub {
    my $self = shift;

    return unless @_;

    die "Multiple inheritance is not supported for Bread::Board::Declare classes"
        if @_ > 1;

    return if $_[0]->isa('Bread::Board::Container');

    die "Cannot inherit from " . join(', ', @_)
      . " because Bread::Board::Declare classes must inherit"
      . " from Bread::Board::Container";
};

no Moose::Role;

1;
