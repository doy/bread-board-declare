package MooseX::Bread::Board::Meta::Role::Class;
use Moose::Role;

use Bread::Board::Service;
use List::MoreUtils qw(any);

has services => (
    traits  => ['Array'],
    isa     => 'ArrayRef[Bread::Board::Service]',
    default => sub { [] },
    handles => {
        add_service  => 'push',
        services     => 'elements',
        has_services => 'count',
    },
);

sub has_any_services {
    my $self = shift;
    return any { $_->has_services }
           grep { Moose::Util::does_role($_, __PACKAGE__) }
           map { $_->meta }
           $self->linearized_isa;
}

sub get_all_services {
    my $self = shift;
    return map { $_->services }
           grep { Moose::Util::does_role($_, __PACKAGE__) }
           map { $_->meta }
           $self->linearized_isa;
}

before superclasses => sub {
    my $self = shift;

    return unless @_;
    return if any { $_->isa('Bread::Board::Container') } @_;

    die "Cannot inherit from " . join(', ', @_)
      . " because MooseX::Bread::Board classes must inherit"
      . " from Bread::Board::Container";
};

no Moose::Role;

1;
