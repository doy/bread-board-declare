package Bread::Board::Declare;
use Moose::Exporter;
# ABSTRACT: create Bread::Board containers as normal Moose objects

use Bread::Board ();

=head1 SYNOPSIS

  package MyApp;
  use Bread::Board::Declare;

=head1 DESCRIPTION

=cut

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

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-bread-board-declare at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bread-Board-Declare>.

=head1 SEE ALSO

L<Bread::Board>

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc Bread::Board::Declare

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bread-Board-Declare>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bread-Board-Declare>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bread-Board-Declare>

=item * Search CPAN

L<http://search.cpan.org/dist/Bread-Board-Declare>

=back

=cut

1;
