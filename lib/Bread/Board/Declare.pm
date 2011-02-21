package Bread::Board::Declare;
use Moose::Exporter;
# ABSTRACT: create Bread::Board containers as normal Moose objects

use Bread::Board ();

=head1 SYNOPSIS

  package MyApp;
  use Moose;
  use Bread::Board::Declare;

  has dsn => (
      is    => 'ro',
      isa   => 'Str',
      value => 'dbi:mysql:my_db',
  );

  has dbic => (
      is           => 'ro',
      isa          => 'MyApp::Model::DBIC',
      dependencies => ['dsn'],
      lifecycle    => 'Singleton',
  );

  has tt => (
      is  => 'ro',
      isa => 'MyApp::View::TT',
  );

  has controller => (
      is           => 'ro',
      isa          => 'MyApp::Controller',
      dependencies => {
          model => 'dbic',
          view  => 'tt',
      },
  );

  MyApp->new->controller; # new controller object with new model and view
  MyApp->new(
      model => MyApp::Model::KiokuDB->new,
  )->controller; # new controller object with new view and kioku model

=head1 DESCRIPTION

This module is a L<Moose> extension which allows for declaring L<Bread::Board>
container classes in a more straightforward and natural way. It sets up
L<Bread::Board::Container> as the superclass, and creates services associated
with each attribute that you create, according to these rules:

=over 4

=item

If the C<< service => 0 >> option is passed to C<has>, no service is created.

=item

If the C<value> option is passed to C<has>, a L<Bread::Board::Literal>
service is created, with the given value.

=item

If the C<block> option is passed to C<has>, a L<Bread::Board::BlockInjection>
service is created, with the given coderef as the block. In addition to
receiving the service object (as happens in Bread::Board), this coderef will
also be passed the container object.

=item

If the attribute has a type constraint corresponding to a class, a
L<Bread::Board::ConstructorInjection> service is created, with the class
corresponding to the type constraint.

=item

Otherwise, no service is created.

=back

Constructor parameters for services (C<dependencies>, C<lifecycle>, etc) can
also be passed into the attribute definition; these will be forwarded to the
service constructor.

In addition to creating the services, this module also modifies the attribute
reader generation, so that if the attribute has no value, a value will be
resolved from the associated service. It also modifies the C<get> method on
services so that if the associated attribute has a value, that value will be
returned immediately. This allows for overriding service values by passing
replacement values into the constructor, or by calling setter methods.

Note that C<default>/C<builder> doesn't make a lot of sense in this setting, so
they are explicitly disabled. In addition, multiple inheritance would just
cause a lot of problems, so it is also disabled (although single inheritance
and role application works properly).

NOTE: When using this module in roles with Moose versions prior to 2.0, the
attribute trait will need to be applied explicitly to attributes that should
become services, as in:

  has attr => (
      traits => ['Service'],
      is     => 'ro',
      isa    => 'Str',
      value  => 'value',
  )

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
