package Bread::Board::Declare::Role::Service;
use Moose::Role;
# ABSTRACT: role for Bread::Board::Service objects

=head1 DESCRIPTION

This role modifies L<Bread::Board::Service> objects for use in
L<Bread::Board::Declare>. It holds a reference to the attribute object that the
service is associated with, and overrides the C<get> method to prefer to return
the value in the attribute, if it exists.

=cut

=attr associated_attribute

The attribute metaobject that this service is associated with.

=cut

has associated_attribute => (
    is       => 'ro',
    isa      => 'Class::MOP::Attribute',
    required => 1,
    weak_ref => 1,
);

around get => sub {
    my $orig = shift;
    my $self = shift;

    my $container = $self->parent_container;
    my $attr = $self->associated_attribute;

    if ($attr->has_value($container)) {
        return $attr->get_value($container);
    }

    my $val = $self->$orig(@_);
    $attr->verify_against_type_constraint($val, instance => $container)
        if $attr->has_type_constraint;

    return $val;
};

=method parent_container

Returns the Bread::Board::Declare container object that this service is
contained in.

=cut

sub parent_container {
    my $self = shift;

    my $container = $self;
    until (!defined($container)
        || ($container->isa('Bread::Board::Container')
            && $container->does('Bread::Board::Declare::Role::Object'))) {
        $container = $container->parent;
    }
    die "Couldn't find associated object!" unless defined $container;

    return $container;
}

no Moose::Role;

1;
