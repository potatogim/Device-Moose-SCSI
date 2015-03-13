#!/usr/bin/perl -c

package Device::Moose::SCSI;
{
    $Device::Moose::SCSI::AUTHORITY = "cpan:potatogim";
    $Device::Moose::SCSI::VERSION   = "0.12";
};

use Moose;
use namespace::clean    -except => "meta";
use utf8;

use Carp;
use IO::File;
use Fcntl               qw/:mode/;

use Device::Moose::SCSI::Constants  qw/%SCSI_CMD/;


#-----------------------------------------------------------------------------
#   Attributes
#-----------------------------------------------------------------------------
has "devices" =>
(
    is      => "ro",
    isa     => "HashRef",
    builder => "_build_devices",
);

has "debug" =>
(
    is  => "rw",
    isa => "Bool",
);

has "_fh" =>
(
    is        => "ro",
    isa       => "FileHandle | Undef",
    writer    => "_set_fh",
    predicate => "is_opened",
);

has "_device" =>
(
    is     => "ro",
    isa    => "Str",
    writer => "_set_device",
    reader => "device",
);


#-----------------------------------------------------------------------------
#   Private Methods
#-----------------------------------------------------------------------------
sub _build_devices
{
    my $self = shift;
    my %args = @_;

    my $dh = undef;

    if (!opendir($dh, "/dev"))
    {
        carp "Cannot read /dev: $!";
        return undef;
    }

    my %devices = ();

    foreach my $file (readdir($dh))
    {
        if (! -r "/dev/$file")
        {
            carp "Cannot read /dev/$file: $!";
            return undef;
        }

        my @stat = lstat("/dev/$file");

        # next if stat() failed
        next unless (scalar(@stat));

        # next if file isn't character special or block device
        next unless (S_ISCHR($stat[2]) || S_ISBLK($stat[2]));

        my $major = int($stat[6] / 256);

        # major number of /dev/sg* is 21 and /dev/sd* is 8
        next unless ($major == 21 || $major == 8);

        my $minor = $stat[6] % 256;

        @{$devices{"/dev/$file"}}{qw/device major minor/}
            = ("/dev/$file", $major, $minor);
    }

    return \%devices;
}


#-----------------------------------------------------------------------------
#   Public Methods
#-----------------------------------------------------------------------------
sub enumerate
{
    my $self = shift;
    my %args = @_;

    return sort { $a cmp $b } keys(%{$self->devices});
}

sub open
{
    my $self = shift;
    my %args = @_;

    if (!defined($args{device}))
    {
        carp "Invalid parameter: device";
        return -1;
    }

    my $fh     = $self->devices->{$args{device}}->{fh};
    my $device = $args{device};
    my $major  = undef;
    my $minor  = undef;

    if (!defined($fh))
    {
        ($fh, $major, $minor) = _open($args{device});

        @{$self->devices->{$args{device}}}{qw/device fh major minor/}
            = ($args{device}, $fh, $major, $minor);
    }

    $self->_set_fh($fh);
    $self->_set_device($device);

    return 0;
}

sub execute
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        carp "Cannot find a opened SCSI device";
        return undef;
    }

    my ($command, $wanted, $data) = @args{qw/command wanted data/};

    $data = "" unless(defined($data));

    my $header = pack ("i4 I x16"
        , 36 + length($command) + length($data) # int pack_len
        , 36 + $wanted                          # int reply_len
        , 0                                     # int pack_id
        , 0                                     # int result
        , length($command) == 12);              # unsigned int twelve_byte:1

    my $iobuf = $header . $command . $data;

    my $ret = syswrite($self->_fh, $iobuf, length($iobuf));

    if (!defined($ret))
    {
        carp "Cannot write to the " . $self->device . ": $!";
        return undef;
    }

    $ret = sysread($self->_fh, $iobuf, 36 + $wanted);

    if (!defined($ret))
    {
        carp "Cannot read from the " . $self->device . ": $!";
        return undef;
    }

    return (substr($iobuf, 36), substr($iobuf, 15, 16));
}

sub inquiry
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        carp "Cannot find a opened SCSI device";
        return undef;
    }

    my ($model, undef) = $self->execute(
        command => pack("C x3 C x1", 0x12, 96)
        , wanted => 96);

    my ($serial, undef) = $self->execute(
        command => pack("C3 x1 C x1", 0x12, 0x01, 0x80, 0xfc)
        , wanted => 96);

    my %enq;

    @enq{qw/DEVICE VENDOR PRODUCT REVISION SERIAL/} = (
        unpack("C x7 A8 A16 A4", $model),
        substr($serial, 4, unpack("C", substr($serial, 3, 1)))
    );

    return \%enq;
}

sub test_unit_ready
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        warn "[ERR] Failed to access a SCSI device";
        return -1;
    }

    print_header($SCSI_CMD{TEST_UNIT_READY}) if ($self->debug);

    my $lun = defined($args{lun}) ? $args{lun} : 0x00;

    my ($result, $sense) = $self->execute (
        command  => pack ("C C C C C C"
            , $SCSI_CMD{TEST_UNIT_READY}  # command
            , $lun & 0xe0               # LUN/Reserved
            , 0x00                      # Reserved
            , 0x00                      # Reserved
            , 0x00                      # Reserved
            , 0x00                      # Control
        )
        , wanted => 32
    );

    hexdump($result) if ($self->debug);
    print_sense($sense) if ($self->debug);

#    return ($sense->[$SCSI_IND{ASC}] != ($SCSI_ASC{NO_MEDIUM} >> 8)
#                || $sense->[$SCSI_IND{ASCQ}] != $SCSI_ASC{NO_MEDIUM} & 0xff);

    return $sense;
}

sub request_sense
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        warn "[ERR] Failed to access a SCSI device";
        return -1;
    }

    print_header($SCSI_CMD{REQUEST_SENSE}) if ($self->debug);

    my $lun         = $args{lun};
    my $mx_resp_len = $args{max_resp_len};

    $lun         = 0x00 if (!defined($lun));
    $mx_resp_len = 0xff if (!defined($mx_resp_len));

    my ($result, $sense) = $self->execute (
        command => pack ("C C C C C C"
            , $SCSI_CMD{REQUEST_SENSE}    # Operation code
            , $lun & 0xe0               # Logical unit number/Reserved
            , 0x00                      # Reserved
            , 0x00                      # Reserved
            , 0x00                      # Allocation length
            , 0x00                      # Control
        )
        , wanted => 32
    );

    hexdump($result) if ($self->debug);
    print_sense($sense) if ($self->debug);

    return $sense;
}

sub recv_diagnostic_results
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        warn "[ERR] Failed to access a SCSI device";
        return -1;
    }

    return;
}

sub send_diagnostic
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        warn "[ERR] Failed to access a SCSI device";
        return -1;
    }

    return;
}

sub read_element_status
{
    my $self = shift;
    my %args = @_;

    if (!$self->is_opened())
    {
        warn "[ERR] Failed to access a SCSI device";
        return -1;
    }

    print_header($SCSI_CMD{READ_ELEMENT_STATUS}) if ($self->debug);

    my $lun    = defined($args{lun}) ? $args{lun} : 0x00;
    my $voltag = defined($args{voltag}) ? $args{voltag} : 0x00;
    my $etype  = defined($args{etype}) ? $args{etype} : 0x00;

    my ($result, $sense) = $self->execute (
        command => pack("C12"
            , $SCSI_CMD{READ_ELEMENT_STATUS}    # READ ELEMENT STATUS
            , $lun    & 0xe0                    # Logical unit number
              | $voltag & 0x10                  # VolTag
              | $etype  & 0x0f                  # Element type code
            , 0x00                              # Starting element address MSB
            , 0x00                              # Starting element address LSB
            , 0x00                              # Number of elements MSB
            , 0x00                              # Number of elements LSB
            , 0x00                              # (Reserved)
            , 0x00                              # Allocation length MSB
            , 0x00                              # Allocation length
            , 0x00                              # Allocation length LSB
            , 0x00                              # (Reserved)
            , 0x00                              # Control
        )
        , wanted => 32);

    hexdump($result) if ($self->debug);
    print_sense($sense) if ($self->debug);

    return $sense;
}


#-----------------------------------------------------------------------------
#   Class Methods
#-----------------------------------------------------------------------------
sub _open
{
    my $path = shift;
    my @stat = lstat($path);

    # next if stat() failed
    if (!scalar(@stat))
    {
        carp "Cannot stat $path: $!";
        return undef;
    }

    # next if file isn't character special or block device
    if (!(S_ISCHR($stat[2]) || S_ISBLK($stat[2])))
    {
        carp "This is not character/block device: $path";
        return undef;
    }

    my $major = int($stat[6] / 256);

    # major number of /dev/sg* is 21 and /dev/sd* is 8
    if (!($major == 21 || $major == 8))
    {
        carp "This is not SCSI device: $path";
        return undef;
    }

    my $minor = $stat[6] % 256;

    my $fh = IO::File->new("+<$path");

    if (!defined($fh))
    {
        carp "Cannot open the $path: $!";
        return undef;
    }

    return ($fh, $major, $minor);
}

sub hexdump
{
    my $data = shift;

    printf "     %4s\n", join(" ", map { sprintf("%4d", $_); } 1..10);

    for (my $i=0, my $limit=length($data)/10 ; $i<$limit ; ++$i)
    {
        my @data = unpack("C10", substr($data, ($i) * 10, 10));

        printf "%4s %s\n", $i, join(" ", map { sprintf("0x%02x", $_); } @data);
    }
}

sub print_header
{
    my $opcode = shift;
    my $opname = undef;

    foreach my $key (keys(%SCSI_CMD))
    {
        if ($SCSI_CMD{$key} == $opcode)
        {
            $opname = $key;
            last;
        }
    }

    printf "OPERATION: %s\n", !defined($opname) ? "Unknown" : $opname;
}

sub print_sense
{
    my $sense = shift;

    print "\n";

    foreach (my $i=0; $i<2; ++$i)
    {
        printf "  S%d %s\n", $i, join(" "
            , map { sprintf("0x%02x", $_); } @{$sense}[$i..$i+9]);
    }
}


#-----------------------------------------------------------------------------
#   Life Cycle
#-----------------------------------------------------------------------------
sub BUILD
{
    my $self = shift;
    my $args = shift;

    if (defined($args->{device}))
    {
        $self->open(device => $args->{device});
    }

    return;
}

__PACKAGE__->meta->make_immutable();
1;

__END__

=encoding utf8

=head1 NAME

Device::Moose::SCSI - Reimplementation of Device::SCSI with Moose.

=head1 SYNOPSIS

    use Device::Moose::SCSI;

    my $device = Device::Moose::SCSI->new(device => "/dev/sg0");

    # INQUIRY
    my $inquiry = $device->inquiry();

    map {
        printf ("%s : %s\n", $key, $inquiry->{$key});
    } keys(%{$inquiry});

    # above code prints such as
    #
    # PRODUCT : MR9240-4i
    # SERIAL : 0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
    # REVISION : 2.13
    # VENDOR : LSI
    # DEVICE : 0

    # TESTUNITREADY
    my ($result, $sense) = $device->execute (
        command => pack("C x5", 0x00)
        , wanted => 32
    );

    or

    my $handle = Device::Moose::SCSI->new();

    foreach my $device ($handle->enumerate())
    {
        printf "Device %s\n", $device;

        $handle->open(device => $device);

        # TESTUNITREADY
        $result = $handle->test_unit_ready();

        printf "Result : %d\n", $result;
    }

=head1 DESCRIPTION

C<Device::Moose::SCSI> reimplementation of Device::SCSI using Moose.

See L<Device::SCSI> for detail information.

Refer to L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO>
if you need to know how to SCSI programming with Linux.

=head1 ATTRIBUTES

=over

=item B<fh>

=item B<name>

=back

=head1 METHODS

=over

=item B<enumerate>

=item B<open>

=item B<close>

=item B<execute>

=item B<inquiry>

=back

=head2 Lifecycle methods

=over

=item B<BUILD>

=back

=head1 AUTHOR

Ji-Hyeon Gim <potatogim@potatogim.net>

=head1 CONTRIBUTORS

=head1 COPYRIGHT AND LICENSE

Copyright(c) 2015, by Ji-Hyeon Gim <potatogim@potatogim.net>

This is free software; you can redistribute it and/or modify it
under the same terms as Perl 5 itself at:

L<http://www.perlfoundation.org/artistic_license_2_0>

You may obtain a copy of the full license at:

L<http://www.perl.com/perl/misc/Artistic.html>

=head1 SEE ALSO

L<Device::SCSI>, L<Moose>

=cut

