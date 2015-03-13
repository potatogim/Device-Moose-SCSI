# Device-Moose-SCSI

Reimplementation of Device::SCSI using Moose.

## SYNOPSIS
```perl
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
```

```perl
    my $handle = Device::Moose::SCSI->new();

    foreach my $device ($handle->enumerate())
    {
        printf "Device %s\n", $device;
        $handle->open(device => $device);
        # TESTUNITREADY
        $result = $handle->test_unit_ready();
        printf "Result : %d\n", $result;
    }
```
## DESCRIPTION
**Device::Moose::SCSI** is reimplementation of Device::SCSI using Moose.

See [Device::SCSI](https://metacpan.org/pod/Device::SCSI) for detail information.

Refer to [The Linux SCSI programming HOWTO](http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO)

if you need to know how to SCSI programming with Linux.

## ATTRIBUTES
* **fh**
* **name**

## METHODS
* **enumerate**
* **open**
* **close**
* **execute**
* **inquiry**

## AUTHOR

Ji-Hyeon Gim `<potatogim@potatogim.net>`

## CONTRIBUTORS

## COPYRIGHT AND LICENSE
Copyright(c) 2015, by Ji-Hyeon Gim `<potatogim@potatogim.net>`

This is free software; you can redistribute it and/or modify it under the same terms as Perl 5 itself at:
http://www.perlfoundation.org/artistic_license_2_0

You may obtain a copy of the full license at:
http://www.perl.com/perl/misc/Artistic.html

## SEE ALSO
* [Device::SCSI](https://metacpan.org/pod/Device::SCSI)
* [Moose](https://metacpan.org/pod/Moose)
