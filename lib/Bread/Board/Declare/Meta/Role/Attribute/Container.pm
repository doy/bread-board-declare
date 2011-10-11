package Bread::Board::Declare::Meta::Role::Attribute::Container;
use Moose::Role;
Moose::Util::meta_attribute_alias('Container');

use Class::Load 'load_class';

has dependencies => (
    is        => 'ro',
    isa       => 'Bread::Board::Service::Dependencies',
    coerce    => 1,
    predicate => 'has_dependencies',
);

after attach_to_class => sub {
    my $self = shift;

    my $tc = $self->type_constraint;
    if ($tc && $tc->isa('Moose::Meta::TypeConstraint::Class')) {
        load_class($tc->class);
        confess "Subcontainers must inherit from Bread::Board::Container"
            unless $tc->class->isa('Bread::Board::Container');
    }
    else {
        confess "Attributes for subcontainers must specify a class type constraint";
    }
};

around get_value => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;

    return $self->$orig($instance)
        if $self->has_value($instance)
        || $self->has_default
        || $self->has_builder;

    my $val = $instance->get_sub_container($self->name);

    if ($self->has_type_constraint) {
        $val = $self->type_constraint->coerce($val)
            if $self->should_coerce;

        $self->verify_against_type_constraint($val, instance => $instance);
    }

    return $val;
};

around _inline_instance_get => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;
    return 'do {' . "\n"
            . 'my $val;' . "\n"
            . 'if (' . $self->_inline_instance_has($instance) . ') {' . "\n"
                . '$val = ' . $self->$orig($instance) . ';' . "\n"
            . '}' . "\n"
            . 'else {' . "\n"
                . '$val = ' . $instance . '->get_sub_container(\'' . $self->name . '\');' . "\n"
                . join("\n", $self->_inline_check_constraint(
                    '$val',
                    '$type_constraint',
                    '$type_message',
                )) . "\n"
            . '}' . "\n"
            . '$val' . "\n"
        . '}';
};

no Moose::Role;

1;
