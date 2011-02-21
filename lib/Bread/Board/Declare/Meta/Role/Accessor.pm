package Bread::Board::Declare::Meta::Role::Accessor;
use Moose::Role;

around _inline_get => sub {
    my $orig = shift;
    my $self = shift;
    my ($instance) = @_;

    my $attr = $self->associated_attribute;

    return 'do {' . "\n"
             . 'my $val;' . "\n"
             . 'if (' . $self->_inline_has($instance) . ') {' . "\n"
                 . '$val = ' . $self->$orig($instance) . ';' . "\n"
             . '}' . "\n"
             . 'else {' . "\n"
                 . '$val = ' . $instance . '->get_service(\'' . $attr->name . '\')->get;' . "\n"
                 . $self->_inline_check_constraint('$val')
             . '}' . "\n"
             . '$val' . "\n"
         . '}';
};

no Moose::Role;

1;
