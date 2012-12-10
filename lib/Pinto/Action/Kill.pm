# ABSTRACT: Permanently delete a stack

package Pinto::Action::Kill;

use Moose;

use Pinto::Types qw(StackName StackObject);

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Transactional );

#------------------------------------------------------------------------------

has stack => (
    is       => 'ro',
    isa      => StackName | StackObject,
    required => 1,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $stack = $self->repo->open_stack($self->stack);

    $self->repo->delete_stack_filesystem(stack => $stack);
    $stack->delete;

    return $self->result->changed;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__