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

# test check_state_test.pm for telemetry with no violations
# runs the violations check 20 times and confirms that no
# alerts have been sent out
test_check_state_test_no_violations();

# test check_state_test.pm for a series of MSIDs
# WIP - not tested yet
#test_send_msid_alert('aopcadmd', 3, '.nsunalert');

#test_send_msid_alert('coscs107s', 3, '.scs107alert');

#test_send_msid_alert('3tscpos', 3, '.sim_unsafe_alert');

#test_send_msid_alert('aofstar', 3, '.britalert');

#test_send_msid_alert('aocpestl', 3, '.cpealert');

#test_send_msid_alert('ccsdstmf', 1, '.fmt5alert');

#test_send_msid_alert('ctxapwr', 10, '.ctxpwraalert');

#test_send_msid_alert('ctxbpwr', 10, '.ctxpwrbalert');

#test_send_msid_alert('ctxav', 3, '.ctxavalert');

#test_send_msid_alert('ctxbv', 3, '.ctxbvalert');

## test_send_msid_alert('5hse202', 5, '.hkp27valert');  - WORK ON TELEM SETUP

#test_send_msid_alert('2shldbrt', 3, '.hrc_shld_alert');

#test_send_msid_alert('pline03t', 3, '.pline03talert');

#test_send_msid_alert('pline04t', 3, '.pline04talert');

#test_send_msid_alert('3ldrtno', 3, '.ldrtnoalert');

#test_send_msid_alert('n15vbvl', 10, '.n15vbvlalert');

#test_send_msid_alert('p15vbvl', 10, '.p15vbvlalert');

#test_send_msid_alert('p05vbvl', 10, '.p05vbvlalert');

#test_send_msid_alert('p24vbvl', 10, '.p24vbvlalert');

#test_send_msid_alert('prbscr', 10, '.prbscralert');

