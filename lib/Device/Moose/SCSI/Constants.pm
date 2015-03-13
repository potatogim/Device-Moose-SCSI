#!/usr/bin/perl -c

package Device::Moose::SCSI::Constants;
{
    $Device::Moose::SCSI::Constants::AUTHORITY = "cpan:potatogim";
    $Device::Moose::SCSI::Constants::VERSION   = "0.10";
};

use strict;
use warnings;
use utf8;

use Exporter    qw/import/;

my %SCSI_CMD;
my %SCSI_IND;
my %SCSI_SC;
my %SCSI_SK;
my %SCSI_HC;
my %SCSI_DC;
my %SCSI_ASC;

BEGIN
{
    # Operation codes
    %SCSI_CMD = (
        # - All device types
        TEST_UNIT_READY              => 0x00,
        REQUEST_SENSE                => 0x03,
        INQUIRY                      => 0x12,
        MODE_SELECT6                 => 0x15,   # 6
        MODE_SENSE6                  => 0x1a,   # 6
        COPY                         => 0x18,
        COMPARE                      => 0x39,
        COPY_AND_VERIFY              => 0x3a,
        WRITE_BUFFER                 => 0x3b,
        READ_BUFFER                  => 0x3c,
        CHANGE_DEFINITION            => 0x40,
        LOG_SELECT                   => 0x4c,
        LOG_SENSE                    => 0x4d,
        MODE_SELECT10                => 0x55,   # 10
        MODE_SENSE10                 => 0x5a,   # 10

        # - Direct-access devices
        REZERO_UNIT                  => 0x01,
        FORMAT_UNIT                  => 0x04,
        REASSIGN_BLOCKS              => 0x07,
        READ6                        => 0x08,   # 6
        WRITE6                       => 0x0a,   # 6
        SEEK6                        => 0x0b,   # 6
        #RESERVE                      => 0x16,
        RELEASE                      => 0x17,
        START_STOP_UNIT              => 0x1b,
        PREVENT_ALLOW_MEDIUM_REMOVAL => 0x1e,
        READ_CAPACITY                => 0x25,
        READ10                       => 0x28,   # 10
        WRITE10                      => 0x2a,   # 10
        SEEK10                       => 0x2b,   # 10
        WRITE_AND_VERIFY             => 0x2e,
        VERIFY                       => 0x2f,
        SEARCH_DATA_HIGH             => 0x30,
        SEARCH_DATA_EQUAL            => 0x31,
        SEARCH_DATA_LOW              => 0x32,
        SET_LIMITS                   => 0x33,
        PRE_FETCH                    => 0x34,
        SYNCHRONIZE_CACHE            => 0x35,
        LOCK_UNLOCK_CACHE            => 0x36,
        READ_DEFECT_DATA             => 0x37,
        READ_LONG                    => 0x3e,
        WRITE_LONG                   => 0x3f,
        WRITE_SAME                   => 0x41,
        READ_ELEMENT_STATUS          => 0xb8,
    );

    # Index
    %SCSI_IND = (
        ASC     => 12,
        ASCQ    => 13,
    );

    # Status codes
    %SCSI_SC = (
        GOOD                 => 0x0,
        CHECK_CONDITION      => 0x1,
        CONDITION_GOOD       => 0x2,
        BUSY                 => 0x4,
        INTERMEDIATE_GOOD    => 0x8,
        INTERMEDIATE_C_GOOD  => 0xa,
        RESERVATION_CONFLICT => 0xc,
    );

    # Sense keys
    # Follow the URL for getting detail description.
    # URL : http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-21.html#sec-sensekeys
    %SCSI_SK = (
        NO_SENSE        => 0x0,
        RECOVERED_ERROR => 0x1,
        NOT_READY       => 0x2,
        MEDIUM_ERROR    => 0x3,
        HARDWARE_ERROR  => 0x4,
        ILLEGAL_REQUEST => 0x5,
        UNIT_ATTENTION  => 0x6,
        DATA_PROTECT    => 0x7,
        BLANK_CHECK     => 0x8,
        VENDOR_SPECIFIC => 0x9,
        COPY_ABORTED    => 0xa,
        ABORTED_COMMAND => 0xb,
        EQUAL           => 0xc,
        VOLUME_OVERFLOW => 0xd,
        MISCOMPARE      => 0xe,
        #RESERVED        => 0xf,
    );

    # Host codes
    %SCSI_HC = (
        DID_OK         => 0x00,     # No error
        DID_NO_CONNECT => 0x01,     # Couldn't connect before timeout period
        DID_BUS_BUSY   => 0x02,     # BUS stayed busy through time out period
        DID_TIME_OUT   => 0x03,     # TIMED OUT for other reason
        DID_BAD_TARGET => 0x04,     # BAD target
        DID_ABORT      => 0x05,     # Told to abort for some other reason
        DID_PARITY     => 0x06,     # Parity error
        DID_ERROR      => 0x07,     # internal error
        DID_RESET      => 0x08,     # Reset by somebody
        DID_BAD_INTR   => 0x09,     # Got an interrupt we weren't expecting
    );

    # Driver codes
    %SCSI_DC = (
        DRIVER_OK      => 0x00,     # No error
        DRIVER_BUSY    => 0x01,     # not used
        DRIVER_SOFT    => 0x02,     # not used
        DRIVER_MEDIA   => 0x03,     # not used
        DRIVER_ERROR   => 0x04,     # internal driver error
        DRIVER_INVALID => 0x05,     # finished (DID_BAD_TARGET or DID_ABORT)
        DRIVER_TIMEOUT => 0x06,     # finished with timeout
        DRIVER_HARD    => 0x07,     # finished with fatal error
        DRIVER_SENSE   => 0x08,     # had sense information available

        SUGGEST_RETRY  => 0x10,     # retry the SCSI request
        SUGGEST_ABORT  => 0x20,     # abort the request
        SUGGEST_REMAP  => 0x30,     # remap the block (not yet implemented)
        SUGGEST_DIE    => 0x40,     # let the kernel panic
        SUGGEST_SENSE  => 0x80,     # get sense information from the device
        SUGGEST_IS_OK  => 0xff,     # nothing to be done
    );

    # Additional Sense Codes and Qualifiers
    %SCSI_ASC = (
        NO_ASC                           => 0x0000,
        IOP_TERM                         => 0x0006,
        NO_IND_SIG                       => 0x0100,
        NOS_SEEK_CMPL                    => 0x0200,
        PERIF_DEV_WR_FAULT               => 0x0300,
        LU_NOT_READY                     => 0x0400,
        LU_INPROC_READY                  => 0x0401,
        LU_NEED_INIT                     => 0x0402,
        LU_NEED_INT                      => 0x0403,
        LU_FORMAT_INPROG                 => 0x0404,
        LU_NOT_RESP                      => 0x0500,
        REF_POS_FOUND                    => 0x0600,
        MULTI_PERIF_DEVS_SELECTED        => 0x0600,
        LU_COMM_FAILURE                  => 0x0800,
        LU_COMM_TIMEOUT                  => 0x0801,
        LU_COMM_PARITY_ERR               => 0x0801,
        TRACK_FOLLOWING_ERROR            => 0x0900,
        ERR_LOG_OVERFLOW                 => 0x0a00,
        WR_ERR_RECOV_WITH_AUTO_REALLOC   => 0x0c01,
        WR_ERR_AUTO_REALLOC_FAILED       => 0x0c02,
        ID_CRC_OR_ECC_ERROR              => 0x1000,
        UNRECOV_RD_ERR                   => 0x1100,
        RD_RET_EXHAUSTED                 => 0x1101,
        ERR_TOO_LONG                     => 0x1102,
        MULTI_RD_ERRS_                   => 0x1103,
        RD_ERR_AUTO_REALLOC_FAILED       => 0x1104,
        MISSCORR_ERR                     => 0x110a,
        RD_ERR_RCMD_REASSIGN             => 0x110b,
        RD_ERR_RCMD_REWRITE              => 0x110c,
        ADDRMARK_NOT_FOUND_ID            => 0x1200,
        ADDRMARK_NOT_FOUND_DATA          => 0x1300,
        REC_ENTITY_NOT_FOUND             => 0x1400,
        REC_NOT_FOUND                    => 0x1401,
        RAND_POS_ERR                     => 0x1500,
        MECH_POS_ERR                     => 0x1501,
        POS_ERR                          => 0x1502,
        DSM_ERR                          => 0x1600,
        RECOVDATA_NO_ERRCORR             => 0x1700,
        RECOVDATA_RETRIES                => 0x1701,
        RECOVDATA_POS_HEAD_OFFSET        => 0x1702,
        RECOVDATA_NEG_HEAD_OFFSET        => 0x1703,
        RECOVDATA_PREV_SECTOR_ID         => 0x1705,
        RECOVDATA_AUTO_REALLOC_NO_ECC    => 0x1706,
        RECOVDATA_RCMD_REASSIGN_NO_ECC   => 0x1707,
        RECOVDATA_RCMD_REWRITE_NO_ECC    => 0x1708,
        RECOVDATA_ERRCORR                => 0x1800,
        RECOVDATA_ERRCORR_RETRIES        => 0x1801,
        RECOVDATA_AUTO_REALLOC           => 0x1802,
        RECOVDATA_RCMD_REASSIGN          => 0x1805,
        RECOVDATA_RCMD_REWRITE           => 0x1806,
        DEFECT_LIST_ERR                  => 0x1900,
        DEFECT_LIST_NOT_AVAIL            => 0x1901,
        DEFECT_LIST_ERR_PRIMARY          => 0x1902,
        DEFECT_LIST_ERR_GROWN            => 0x1903,
        PARAM_LIST_LEN_ERR               => 0x1a00,
        SYNC_DATA_TRANS_ERR              => 0x1b00,
        DEFECT_LIST_NOT_FOUND            => 0x1c00,
        PRIMARY_DEFECT_LIST_NOT_FOUND    => 0x1c01,
        GROWN_DEFECT_LIST_NOT_FOUND      => 0x1c02,
        VERIFY_MISSCMP                   => 0x1d00,
        RECOVID_ECC                      => 0x1e00,
        INVALID_CMD                      => 0x2000,
        LBA_OUT_OF_RANGE                 => 0x2100,
        # (SHOULD USE 20 00, 24 00, OR 26 00)
        ILLEGAL_FUNC                     => 0x2200,
        INVALID_FIELD_CDB                => 0x2400,
        LU_NOT_SUPPORTED                 => 0x2500,
        INVALID_FIELD_PARAM_LIST         => 0x2600,
        PARAM_NOT_SUPPORTED              => 0x2601,
        INVALID_PARAM_VALUE              => 0x2602,
        THRSH_PARAM_NOT_SUPPORTED        => 0x2603,
        WRITE_PROTECTED                  => 0x2700,
        NOT_READY_TRANSITION             => 0x2800,
        RESET_OCCURED                    => 0x2900,
        PARAM_CHANGED                    => 0x2a00,
        MODE_PARAM_CHANGED               => 0x2a01,
        LOG_PARAM_CHANGED                => 0x2a02,
        HOST_CANNOT_DISCONN              => 0x2b00,
        CMD_SEQ_ERR                      => 0x2c00,
        CMD_CLRD_ANR_INITIATOR           => 0x2f00,
        INCOMPATIBLE_MEDIUM              => 0x3000,
        UNKNOWN_FORMAT                   => 0x3001,
        INCOMPATIBLE_FORMAT              => 0x3001,
        CLEANING_CART_INSTALLED          => 0x3003,
        MEDIUM_FORMAT_CORRUPTED          => 0x3100,
        FORMAT_CMD_FAILED                => 0x3101,
        NO_DEFECT_SPARE_LOCATION_AVAIL   => 0x3200,
        DEFECT_LIST_UPDATE_FAILURE       => 0x3201,
        ROUNDED_PARAMETER                => 0x3700,
        PARAM_SAVING_NOT_SUPPORTED       => 0x3900,
        NO_MEDIUM                        => 0x3a00,
        ID_MSG_INVALID                   => 0x3d00,
        LU_NOT_SELF_CONFIGURED_YET       => 0x3e00,
        TARGET_OPER_COND_CHANGED         => 0x3f00,
        MICROCODE_CHANGED                => 0x3f01,
        OPER_DEF_CHANGED                 => 0x3f02,
        INQUIRY_DATA_CHANGED             => 0x3f03,
        # (SHOULD USE 40 NN)
        RAM_FAILURE                      => 0x4000,
        DIAG_FAILURE                     => 0x40ff,
        # (SHOULD USE 40 NN)
        DATA_PATH_FAILURE                => 0x4100,
        # (SHOULD USE 40 NN)
        SELF_TEST_FAILURE                => 0x4200,
        MSG_ERROR                        => 0x4300,
        INTERNAL_TGT_FAILURE             => 0x4300,
        SELECT_FAILURE                   => 0x4500,
        INCMPL_SOFT_RESET                => 0x4600,
        SCSI_PARITY_ERR                  => 0x4700,
        DETECTED_ERR_MSG_RCVD            => 0x4800,
        INVALID_MSG_ERROR                => 0x4900,
        CMD_PHASE_ERR                    => 0x4a00,
        DATA_PHASE_ERR                   => 0x4b00,
        LU_SELFCONF_FAILED               => 0x4c00,
        OVERLAPPED_CMDS                  => 0x4e00,
        MEDIA_LOAD_EJECT_FAILED          => 0x5300,
        MEDIUM_REMOVAL_PREVENTED         => 0x5302,
        OPER_REQ_OR_STATE_CHANGE_INPUT   => 0x5a00,
        OPER_MEDIUM_REMOVAL_REQUEST      => 0x5a01,
        OPER_SELECTED_WRITER_PROTECT     => 0x5a02,
        OPER_SELECTED_WRITER_PERMIT      => 0x5a03,
        LOG_EXCEPTION                    => 0x5b00,
        THRSH_COND_MET                   => 0x5b01,
        LOG_CNTR_MAX                     => 0x5b02,
        LOG_LIST_CODES_EXHAUSTED         => 0x5b03,
        RPL_STATUS_CHANGE                => 0x5c00,
        SPINDLES_SYNC                    => 0x5c01,
        SPINDLES_NOT_SYNC                => 0x5c02,
    );
};

our @EXPORT_OK = qw/
    %SCSI_CMD %SCSI_IND %SCSI_SC %SCSI_SK %SCSI_HC %SCSI_DC %SCSI_ASC 
/;

1;

__END__

=encoding utf8

=head1 NAME

Device::Moose::SCSI::Constants - Reimplementation of Device::SCSI with Moose.

=head1 SYNOPSIS

=head1 DESCRIPTION

C<Device::Moose::SCSI::Constants> includes some constants for SCSI-2 standard.

See L<Device::Moose::SCSI> for usage of this package.

=head1 CONSTANTS

=head2 Commands

    +==============================-=============+
    |  Command name                |  Operation  |
    |                              |    code     |
    |------------------------------+-------------+
    |  CHANGE DEFINITION           |     40h     |
    |  COMPARE                     |     39h     |
    |  COPY                        |     18h     |
    |  COPY AND VERIFY             |     3Ah     |
    |  INQUIRY                     |     12h     |
    |  LOG SELECT                  |     4Ch     |
    |  LOG SENSE                   |     4Dh     |
    |  MODE SELECT(6)              |     15h     |
    |  MODE SELECT(10)             |     55h     |
    |  MODE SENSE(6)               |     1Ah     |
    |  MODE SENSE(10)              |     5Ah     |
    |  READ BUFFER                 |     3Ch     |
    |  RECEIVE DIAGNOSTIC RESULTS  |     1Ch     |
    |  REQUEST SENSE               |     03h     |
    |  SEND DIAGNOSTIC             |     1Dh     |
    |  TEST UNIT READY             |     00h     |
    |  WRITE BUFFER                |     3Bh     |
    +==============================-=============+

See L<http://www.staff.uni-mainz.de/tacke/scsi/SCSI2-08.html> for detail information.

=head2 Statuses

    +=================================-==============================+
    |       Bits of Status Byte       |  Status                      |
    |  7   6   5   4   3   2   1   0  |                              |
    |---------------------------------+------------------------------|
    |  R   R   0   0   0   0   0   R  |  GOOD                        |
    |  R   R   0   0   0   0   1   R  |  CHECK CONDITION             |
    |  R   R   0   0   0   1   0   R  |  CONDITION MET               |
    |  R   R   0   0   1   0   0   R  |  BUSY                        |
    |  R   R   0   1   0   0   0   R  |  INTERMEDIATE                |
    |  R   R   0   1   0   1   0   R  |  INTERMEDIATE-CONDITION MET  |
    |  R   R   0   1   1   0   0   R  |  RESERVATION CONFLICT        |
    |  R   R   1   0   0   0   1   R  |  COMMAND TERMINATED          |
    |  R   R   1   0   1   0   0   R  |  QUEUE FULL                  |
    |                                 |                              |
    |       All Other Codes           |  Reserved                    |
    |----------------------------------------------------------------|
    |  Key: R = Reserved bit                                         |
    +================================================================+

See L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-21.html#sec-statuscodes> for detail information.

=head2 Sense keys

    +=======-=================+
    | Value | Symbol          |
    |=======|=================|
    | 0x00  | NO_SENSE        |
    | 0x01  | RECOVERED_ERROR |
    | 0x02  | NOT_READY       |
    | 0x03  | MEDIUM_ERROR    |
    | 0x04  | HARDWARE_ERROR  |
    | 0x05  | ILLEGAL_REQUEST |
    | 0x06  | UNIT_ATTENTION  |
    | 0x07  | DATA_PROTECT    |
    | 0x08  | BLANK_CHECK     |
    | 0x0a  | COPY_ABORTED    |
    | 0x0b  | ABORTED_COMMAND |
    | 0x0d  | VOLUME_OVERFLOW |
    | 0x0e  | MISCOMPARE      |
    +=======-=================+

See L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-21.html#sec-sensekeys> for detail information.

=head2 Host codes

    +=======-================-=========================================+
    | Value | Symbol         | Description                             |
    |=======|================|=========================================|
    | 0x00  | DID_OK         | No error                                |
    | 0x01  | DID_NO_CONNECT | Couldn't connect before timeout period  |
    | 0x02  | DID_BUS_BUSY   | BUS stayed busy through time out period |
    | 0x03  | DID_TIME_OUT   | TIMED OUT for other reason              |
    | 0x04  | DID_BAD_TARGET | BAD target                              |
    | 0x05  | DID_ABORT      | Told to abort for some other reason     |
    | 0x06  | DID_PARITY     | Parity error                            |
    | 0x07  | DID_ERROR      | internal error                          |
    | 0x08  | DID_RESET      | Reset by somebody                       |
    | 0x09  | DID_BAD_INTR   | Got an interrupt we weren't expecting   |
    +=======-================-=========================================+

See L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-21.html#sec-hostcodes> for detail information.

=head2 Driver codes

    +=======-================-========================================+
    | Value | Symbol         | Description of Driver status           |
    |=======|================|========================================|
    | 0x00  | DRIVER_OK      | No error                               |
    | 0x01  | DRIVER_BUSY    | not used                               |
    | 0x02  | DRIVER_SOFT    | not used                               |
    | 0x03  | DRIVER_MEDIA   | not used                               |
    | 0x04  | DRIVER_ERROR   | internal driver error                  |
    | 0x05  | DRIVER_INVALID | finished (DID_BAD_TARGET or DID_ABORT) |
    | 0x06  | DRIVER_TIMEOUT | finished with timeout                  |
    | 0x07  | DRIVER_HARD    | finished with fatal error              |
    | 0x08  | DRIVER_SENSE   | had sense information available        |
    |=======|================|========================================|
    | Value | Symbol         | Description of suggestion              |
    |=======|================|========================================|
    | 0x10  | SUGGEST_RETRY  | retry the SCSI request                 |
    | 0x20  | SUGGEST_ABORT  | abort the request                      |
    | 0x30  | SUGGEST_REMAP  | remap the block (not yet implemented)  |
    | 0x40  | SUGGEST_DIE    | let the kernel panic                   |
    | 0x80  | SUGGEST_SENSE  | get sense information from the device  |
    | 0xff  | SUGGEST_IS_OK  | nothing to be done                     |
    +=======-================-========================================+

See L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-21.html#sec-drivercodes> for detail information.

=head2 Additional Sense Codes and ASC-Qualifiers

See L<http://www.tldp.org/HOWTO/archived/SCSI-Programming-HOWTO/SCSI-Programming-HOWTO-22.html> for detail information.

=head1 LIMITATIONS

It only includes SCSI-2 standard specification and ASC/ASCQ for Direct-access devices above all.

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

L<Device::Moose::SCSI>

=cut

