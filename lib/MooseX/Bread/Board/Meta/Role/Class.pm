package MooseX::Bread::Board::Meta::Role::Class;
use Moose::Role;

use Bread::Board::Service;
use List::MoreUtils qw(any);

sub get_all_services {
    my $self = shift;
    return map { $_->associated_service }
           grep { $_->has_associated_service }
           grep { Moose::Util::does_role($_, 'MooseX::Bread::Board::Meta::Role::Attribute') }
           $self->get_all_attributes;
}

before superclasses => sub {
    my $self = shift;

    return unless @_;

    die "Multiple inheritance is not supported for MooseX::Bread::Board classes"
        if @_ > 1;

    return if $_[0]->isa('Bread::Board::Container');

    die "Cannot inherit from " . join(', ', @_)
      . " because MooseX::Bread::Board classes must inherit"
      . " from Bread::Board::Container";
};

no Moose::Role;

1;
