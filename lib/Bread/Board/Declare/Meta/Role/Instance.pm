package Bread::Board::Declare::Meta::Role::Instance;
use Moose::Role;

# XXX: ugh, this should be settable at the attr level, fix this in moose
sub inline_get_is_lvalue { 0 }

no Moose::Role;

1;
