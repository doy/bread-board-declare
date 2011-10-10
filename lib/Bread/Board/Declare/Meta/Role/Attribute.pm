package Bread::Board::Declare::Meta::Role::Attribute;
use Moose::Role;
# ABSTRACT: base attribute metarole for Bread::Board::Declare

use List::MoreUtils 'any';
use Moose::Util 'does_role', 'find_meta';

=attr service

Whether or not to create a service for this attribute. Defaults to true.

=cut

has service => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

# this is kinda gross, but it's the only way to hook in at the right place
# at the moment, it seems
around interpolate_class => sub {
    my $orig = shift;
    my $class = shift;
    my ($options) = @_;

    # we only want to do this on the final recursive call
    return $class->$orig(@_)
        if $options->{metaclass};

    if (exists $options->{service} && !$options->{service}) {
        return $class->$orig(@_);
    }

    my ($new_class, @traits) = $class->$orig(@_);

    return wantarray ? ($new_class, @traits) : $new_class
        if does_role($new_class, 'Bread::Board::Declare::Meta::Role::Attribute::Service');

    my $parent = @traits
        ? (find_meta($new_class)->superclasses)[0]
        : $new_class;
    push @{ $options->{traits} }, 'Bread::Board::Declare::Meta::Role::Attribute::Service';

    return $parent->interpolate_class($options);
};

no Moose::Role;

1;
