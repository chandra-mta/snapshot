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

# test check_state_test.pm on telemetry with no violations
# runs the violations check 20 times and confirms that no
# .*alert files have been created
test_check_state_test_no_violations();

# test check_state_test.pm on telemetry with violations
# and test check_state_test.pm ability to re-arm the alerts

test_check_state_test_send_msid_alert('aopcadmd', 3, '.nsunalert');
test_check_state_test_rearm_msid('aopcadmd', 3, '.nsunalert');

test_check_state_test_send_msid_alert('coscs107s', 3, '.scs107alert'); # sends both scs107 and sim unsafe
test_check_state_test_rearm_msid('coscs107s', 3, '.scs107alert');  # fails, COTLRDSF==EPS required in code

test_check_state_test_send_msid_alert('aofstar', 3, '.britalert');
test_check_state_test_rearm_msid('aofstar', 3, '.britalert');

test_check_state_test_send_msid_alert('aocpestl', 3, '.cpealert');
test_check_state_test_rearm_msid('aocpestl', 3, '.cpealert');

test_check_state_test_send_msid_alert('ccsdstmf', 1, '.fmt5alert'); # no automatic rearming in code

test_check_state_test_send_msid_alert('ctxapwr', 10, '.ctxpwralert');
test_check_state_test_rearm_msid('ctxapwr', 50, '.ctxpwralert');

test_check_state_test_send_msid_alert('ctxbpwr', 10, '.ctxpwralert');
test_check_state_test_rearm_msid('ctxbpwr', 50, '.ctxpwralert');

test_check_state_test_send_msid_alert('ctxav', 3, '.ctxvalert');  # fails but B passes...
test_check_state_test_rearm_msid('ctxav', 3, '.ctxvalert');

test_check_state_test_send_msid_alert('ctxbv', 3, '.ctxvalert');
test_check_state_test_rearm_msid('ctxbv', 3, '.ctxvalert');

test_check_state_test_send_msid_alert('2shldbrt', 3, '.hrc_shld_alert');
test_check_state_test_rearm_msid('2shldbrt', 3, '.hrc_shld_alert');

test_check_state_test_send_msid_alert('pline03t', 3, '.pline03talert');
test_check_state_test_rearm_msid('pline03t', 3, '.pline03talert');

test_check_state_test_send_msid_alert('pline04t', 3, '.pline04talert');
test_check_state_test_rearm_msid('pline04t', 3, '.pline04talert');

test_check_state_test_send_msid_alert('3ldrtno', 3, '.ldrtnoalert');
test_check_state_test_rearm_msid('3ldrtno', 3, '.ldrtnoalert');

test_check_state_test_send_msid_alert('n15vbvl', 10, '.n15vbvlalert');
test_check_state_test_rearm_msid('n15vbvl', 10, '.n15vbvlalert');

test_check_state_test_send_msid_alert('p15vbvl', 10, '.p15vbvlalert');
test_check_state_test_rearm_msid('p15vbvl', 10, '.p15vbvlalert');

test_check_state_test_send_msid_alert('p05vbvl', 10, '.p05vbvlalert');
test_check_state_test_rearm_msid('p05vbvl', 10, '.p05vbvlalert');

test_check_state_test_send_msid_alert('p24vbvl', 10, '.p24vbvlalert');
test_check_state_test_rearm_msid('p24vbvl', 10, '.p24vbvlalert');

test_check_state_test_send_msid_alert('prbscr', 3, '.prbscralert');
test_check_state_test_rearm_msid('prbscr', 3, '.prbscralert');
