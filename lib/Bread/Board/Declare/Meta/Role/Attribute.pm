package Bread::Board::Declare::Meta::Role::Attribute;
use Moose::Role;
Moose::Util::meta_attribute_alias('Service');
# ABSTRACT: attribute metarole for Bread::Board::Declare

use Bread::Board::Types;
use List::MoreUtils qw(any);

use Bread::Board::Declare::BlockInjection;
use Bread::Board::Declare::ConstructorInjection;
use Bread::Board::Declare::Literal;

=head1 DESCRIPTION

This role adds functionality to the attribute metaclass for
L<Bread::Board::Declare> objects.

=cut

=attr service

Whether or not to create a service for this attribute. Defaults to true.

=cut

has service => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
);

=attr block

The block to use when creating a L<Bread::Board::BlockInjection> service.

=cut

has block => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => 'has_block',
);

=attr literal_value

The value to use when creating a L<Bread::Board::Literal> service. Note that
the parameter that should be passed to C<has> is C<value>.

=cut

# has_value is already a method
has literal_value => (
    is        => 'ro',
    isa       => 'Str|CodeRef',
    init_arg  => 'value',
    predicate => 'has_literal_value',
);

=attr lifecycle

The lifecycle to use when creating the service. See L<Bread::Board::Service>
and L<Bread::Board::LifeCycle>.

=cut

has lifecycle => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_lifecycle',
);

=attr dependencies

The dependency specification to use when creating the service. See
L<Bread::Board::Service::WithDependencies>.

=cut

has dependencies => (
    is        => 'ro',
    isa       => 'Bread::Board::Service::Dependencies',
    coerce    => 1,
    predicate => 'has_dependencies',
);

=attr constructor_name

The constructor name to use when creating L<Bread::Board::ConstructorInjection>
services. Defaults to C<new>.

=cut

has constructor_name => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_constructor_name',
);

=attr associated_service

The service object that is associated with this attribute.

=cut

has associated_service => (
    is        => 'rw',
    does      => 'Bread::Board::Service',
    predicate => 'has_associated_service',
);

after attach_to_class => sub {
    my $self = shift;

    return unless $self->service;

    my %params = (
        associated_attribute => $self,
        name                 => $self->name,
        ($self->has_lifecycle
            ? (lifecycle => $self->lifecycle)
            : ()),
        ($self->has_dependencies
            ? (dependencies => $self->dependencies)
            : ()),
        ($self->has_constructor_name
            ? (constructor_name => $self->constructor_name)
            : ()),
    );

    my $tc = $self->has_type_constraint ? $self->type_constraint : undef;

    my $service;
    if ($self->has_block) {
        if ($tc && $tc->isa('Moose::Meta::TypeConstraint::Class')) {
            %params = (%params, class => $tc->class);
        }
        $service = Bread::Board::Declare::BlockInjection->new(
            %params,
            block => $self->block,
        );
    }
    elsif ($self->has_literal_value) {
        $service = Bread::Board::Declare::Literal->new(
            %params,
            value => $self->literal_value,
        );
    }
    elsif ($tc && $tc->isa('Moose::Meta::TypeConstraint::Class')) {
        $service = Bread::Board::Declare::ConstructorInjection->new(
            %params,
            class => $tc->class,
        );
    }
    else {
        $service = Bread::Board::Declare::BlockInjection->new(
            %params,
            block => sub {
                die "Attribute " . $self->name . " did not specify a service."
                  . " It must be given a value through the constructor or"
                  . " writer method before it can be resolved."
            },
        );
    }

    $self->associated_service($service) if $service;
};

after _process_options => sub {
    my $class = shift;
    my ($name, $opts) = @_;

    return unless exists $opts->{default}
               || exists $opts->{builder};
    return unless exists $opts->{class}
               || exists $opts->{block}
               || exists $opts->{value};

    # XXX: uggggh
    return if any { $_ eq 'Moose::Meta::Attribute::Native::Trait::String'
                 || $_ eq 'Moose::Meta::Attribute::Native::Trait::Counter' }
              @{ $opts->{traits} };

    my $exists = exists($opts->{default}) ? 'default' : 'builder';
    die "$exists is not valid when Bread::Board service options are set";
};

around get_value => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;

    return $self->$orig($instance)
        if $self->has_value($instance);

    my $val = $instance->get_service($self->name)->get;

    $self->verify_against_type_constraint($val, instance => $instance)
        if $self->has_type_constraint;

    if ($self->should_auto_deref) {
        if (ref($val) eq 'ARRAY') {
            return wantarray ? @$val : $val;
        }
        elsif (ref($val) eq 'HASH') {
            return wantarray ? %$val : $val;
        }
        else {
            die "Can't auto_deref $val.";
        }
    }
    else {
        return $val;
    }
};

if (Moose->VERSION > 1.9900) {
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
                    . '$val = ' . $instance . '->get_service(\'' . $self->name . '\')->get;' . "\n"
                    . join("\n", $self->_inline_check_constraint(
                        '$val',
                        '$type_constraint',
                        (Moose->VERSION >= 2.0100
                            ? '$type_message'
                            : '$type_constraint_obj'),
                    )) . "\n"
                . '}' . "\n"
                . '$val' . "\n"
            . '}';
    };
}
else {
    around accessor_metaclass => sub {
        my $orig = shift;
        my $self = shift;

        return Moose::Meta::Class->create_anon_class(
            superclasses => [ $self->$orig(@_) ],
            roles        => [ 'Bread::Board::Declare::Meta::Role::Accessor' ],
            cache        => 1
        )->name;
    };
}

no Moose::Role;

1;
