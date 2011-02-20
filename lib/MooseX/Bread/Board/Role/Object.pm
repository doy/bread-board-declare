package MooseX::Bread::Board::Role::Object;
use Moose::Role;
use Bread::Board;

has name => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->meta->name },
);

sub BUILD { }
after BUILD => sub {
    my $self = shift;

    my $meta = Class::MOP::class_of($self);
    return unless $meta->has_services;

    for my $service ($meta->services) {
        $self->add_service($service->clone);
    }
};

no Bread::Board;
no Moose::Role;

1;
