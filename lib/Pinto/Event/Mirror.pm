package Pinto::Event::Mirror;

# ABSTRACT: An event to fill the repository from a mirror

use Moose;

use URI;

use Pinto::Util;
use Pinto::UserAgent;

extends 'Pinto::Event';

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

has 'ua'      => (
    is         => 'ro',
    isa        => 'Pinto::UserAgent',
    default    => sub { Pinto::UserAgent->new() },
    init_arg   => undef,
);

#------------------------------------------------------------------------------

sub execute {
    my ($self) = @_;

    my $local  = $self->config()->get_required('local');
    my $mirror = $self->config()->get_required('mirror');
    my $force  = $self->config()->get('force');

    my $idxmgr = $self->idxmgr();
    my $index_has_changed = $idxmgr->update_mirror_index();
    return 0 unless $index_has_changed or $force;

    for my $file ( $idxmgr->mirrorable_files() ) {

        $self->logger()->debug("Looking at $file");
        my $mirror_uri = URI->new( "$mirror/authors/id/$file" );
        my $destination = Pinto::Util::native_file($local, 'authors', 'id', $file);

        # We assume that the file is up-to-date if it is present.
        # This is usually true, because an archive on the mirror
        # should never change.  But if the transmission was
        # interrupted or somehow corrupted, then our file could be
        # out-of-date.  So the 'force' flag causes us to try and
        # mirror every file, even if we already have it.  Remember
        # that mirror() will still only fetch the file if it thinks
        # the remote one is newer than our local one.

        next if -e $destination and not $self->config()->get('force');

        my $file_has_changed = $self->ua->mirror(url => $mirror_uri, to => $destination);
        $self->logger->log("Mirrored archive $file") if $file_has_changed;
    }

    my $message = "Updated to latest mirror of $mirror";
    $self->_set_message($message);

    return 1;
}

#------------------------------------------------------------------------------

1;

__END__
