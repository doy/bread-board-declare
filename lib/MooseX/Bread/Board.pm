package MooseX::Bread::Board;
use Moose::Exporter;

my (undef, undef, $init_meta) = Moose::Exporter->build_import_methods(
    install => ['import', 'unimport'],
    class_metaroles => {
        attribute => ['MooseX::Bread::Board::Meta::Role::Attribute'],
        class     => ['MooseX::Bread::Board::Meta::Role::Class'],
        instance  => ['MooseX::Bread::Board::Meta::Role::Instance'],
    },
    #role_metaroles => {
        #applied_attribute => ['MooseX::Bread::Board::Meta::Role::Attribute'],
    #},
    base_class_roles => ['MooseX::Bread::Board::Role::Object'],
);

sub init_meta {
    my $package = shift;
    my %options = @_;
    if (my $meta = Class::MOP::class_of($options{for_class})) {
        if ($meta->isa('Class::MOP::Class')) {
            my @supers = $meta->superclasses;
            $meta->superclasses('Bread::Board::Container')
                if @supers == 1 && $supers[0] eq 'Moose::Object';
        }
    }
    $package->$init_meta(%options);
}


1;
