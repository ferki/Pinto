package Pinto::Event::Remove;

# ABSTRACT: An event to remove packages from the repository

use Moose;

use Carp;

extends 'Pinto::Event';

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

has package  => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);


#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $pkg    = $self->package();
    my $author = $self->config()->get_required('author');

    my $idxmgr = $self->idxmgr();
    my $orig_author = $idxmgr->local_author_of(package => $pkg);

    croak "You are $author, but only $orig_author can remove $pkg"
        if defined $orig_author and $author ne $orig_author;

    if (my @removed = $idxmgr->remove_package(package => $pkg)) {
        my $message = Pinto::Util::format_message("Removed packages:", sort @removed);
        $self->_set_message($message);
        return 1;
    }

    $self->logger()->warn("Package $pkg is not in the index");
    return 0;
}

#------------------------------------------------------------------------------

1;

__END__
