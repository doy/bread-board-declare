package Bread::Board::Declare::Role::Object;
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

    my %seen = (
        map { $_->class => $_->name }
            grep { $_->isa('Bread::Board::Declare::ConstructorInjection') && Class::MOP::class_of($_->class) }
                 $meta->get_all_services
    );
    for my $service ($meta->get_all_services) {
        if ($service->isa('Bread::Board::Declare::BlockInjection')) {
            my $block = $service->block;
            $self->add_service(
                $service->clone(
                    block => sub {
                        $block->(@_, $self)
                    },
                )
            );
        }
        elsif ($service->isa('Bread::Board::Declare::ConstructorInjection')
            && $service->associated_attribute->infer
            && (my $meta = Class::MOP::class_of($service->class))) {
            my $inferred = Bread::Board::Service::Inferred->new(
                current_container => $self,
                service           => $service->clone,
                infer_params      => 1,
            )->infer_service($service->class, \%seen);

            $self->add_service($inferred);
            $self->add_type_mapping_for($service->class, $inferred);
        }
        else {
            $self->add_service($service->clone);
        }
    }
};

no Moose::Role;

=pod

=begin Pod::Coverage

BUILD

=end Pod::Coverage

=cut

1;
