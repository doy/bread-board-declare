package MooseX::Bread::Board::Meta::Role::Class;
use Moose::Role;

use Bread::Board::Service;

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

no Moose::Role;

1;
