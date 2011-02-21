package MooseX::Bread::Board::Role::Object;
use Moose::Role;

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
    return unless $meta->has_any_services;

    for my $service ($meta->get_all_services) {
        if ($service->isa('MooseX::Bread::Board::BlockInjection')) {
            my $block = $service->block;
            $self->add_service(
                $service->clone(
                    block => sub {
                        $block->(@_, $self)
                    },
                )
            );
        }
        else {
            $self->add_service($service->clone);
        }
    }
};

no Moose::Role;

1;
