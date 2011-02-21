package Bread::Board::Declare;
use Moose::Exporter;

use Bread::Board ();

my (undef, undef, $init_meta) = Moose::Exporter->build_import_methods(
    install => ['import', 'unimport'],
    class_metaroles => {
        attribute => ['Bread::Board::Declare::Meta::Role::Attribute'],
        class     => ['Bread::Board::Declare::Meta::Role::Class'],
        instance  => ['Bread::Board::Declare::Meta::Role::Instance'],
    },
    (Moose->VERSION >= 1.9900
        ? (role_metaroles => {
               applied_attribute =>
                   ['Bread::Board::Declare::Meta::Role::Attribute'],
           })
        : ()),
    base_class_roles => ['Bread::Board::Declare::Role::Object'],
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
