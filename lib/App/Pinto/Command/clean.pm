package App::Pinto::Command::clean;

# ABSTRACT: delete archives that are not in the index

use strict;
use warnings;

#-----------------------------------------------------------------------------

use base 'App::Pinto::Command';

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

sub validate_args {
    my ($self, $opts, $args) = @_;
    $self->usage_error('Arguments are not allowed') if @{ $args };
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;
    $self->pinto( $opts )->clean();
}

#------------------------------------------------------------------------------

1;

__END__
