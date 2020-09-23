#!/usr/bin/perl
#/usr/bin/env /usr/bin/perl
#/opt/local/bin/perl
#/proj/axaf/bin/perl

# Tests for Chandra snapshot scripts

use tests;

# test snap.pm, subroutine get_data
test_snap_get_data();

# test snap_format.pm, subroutine write_txt
# creates chandra.snapshot in ./tests
test_snap_format_write_txt();

# test snap_format.pm, subroutine write_htm
# creates snarc.html for one snapshot (not an archive)
# in ./tests
test_snap_format_write_htm();

# test check_state_test.pm - keep it identical
# to check_state.pm except the mailing lists
test_check_state_test_no_violations();
test_check_state_test_yellow_violations();
test_check_state_test_violations();
