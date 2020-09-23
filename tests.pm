# tests for chandra snapshot
# MS Sep 2020
# last update: 

sub test_result {
    my $sub_name = shift(@_);
    my $res = shift(@_);

    if ($res == 1) {
        print "Test $sub_name passed.\n";
    } else {
        print "Test $sub_name failed.\n";
    }
}


sub test_snap_get_data {
    use snap;
    my @test_vals;

    my $test_dir = "/home/malgosia/git/snapshot/tests";
    my @tlfiles = ("$test_dir/chandraIRU_00716605019.35.tl", "$test_dir/chandraTEL_00716471275.22.tl");
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    my %h = get_data($test_dir, @ftype);

    foreach my $tlfile (@tlfiles) {
        open FILE, "<$tlfile" or die "opening $tlfile: $!\n";
        $last = $_ while <FILE>;
        close FILE;
        @vals = split ' ', $last;
        push @test_vals, $vals[3];
    }

    my $res = 1;
    if ($test_vals[0] != $h{AIRU2G1I}[1]) {
        $res = 0;
    }
    if ($test_vals[1] != $h{'4OBAVTMF'}[1]) {
        $res = 0;
    }

    test_result('test_snap_get_data', $res);
}


sub test_snap_format_write_txt {
    # Use this for reformatting of chandra.snapshot
    # without running tlogr and switching the alerts
    # off/on
    use snap;
    use comps;
    use snap_format;

    my $test_dir = "/home/malgosia/git/snapshot/tests";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    my $snap_text = write_txt(%h);

    $snapf = "$test_dir/chandra.snapshot";
    open(SF,">$snapf") or die "Cannot create $snapf\n";
    print SF $snap_text;
    close SF;
}


sub test_snap_format_write_htm {
    # Use this for reformatting of chandra.snapshot
    # without running tlogr and switching the alerts
    # off/on
    use snap;
    use comps;
    use snap_format;

    my $test_dir = "/home/malgosia/git/snapshot/tests";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    $h{"2PRBSCR"}[3] = "white";

    my $snap_html = write_htm(%h);

    $snapf = "$test_dir/snarc.html";
    open(SF,">$snapf") or die "Cannot open to $snapf\n";
    print SF "<html><body bgcolor=\"\#555555\"><pre>\n";
    print SF $snap_html;
    close SF;
}


sub test_check_state_test_no_violations {
    # Use this to test check_state_test.pm alerting subroutines
    #   - make sure check_state_test.pm is identical to check_state.pm
    #     except for the mailing lists
    #   - expect 0/0 emails
    use snap;
    use comps;
    use snap_format;
    use check_state_test;

    my $test_dir = "/home/malgosia/git/snapshot";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    # Use the test telemetry files with no violations
    `cp -f $test_dir/tests/tl_no_violations/*.tl $test_dir/`;

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    %h = check_state_test(%h);
}


sub test_send_alerts_yellow_violations {
    # Use this to test check_state_test.pm alerting subroutines
    #   - make sure check_state_test.pm is identical to check_state.pm
    #     except for the mailing lists
    #   - expect 0/2 emails (tank and aacccdpt yellow alerts disabled)
    use snap;
    use comps;
    use snap_format;
    use check_state_test;

    my $test_dir = "/home/malgosia/git/snapshot";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    # Use the test telemetry files with violations
    `cp -f $test_dir/tests/tl_violations/*.tl $test_dir/`;

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    %h = check_state_test(%h);
}


sub test_send_alerts_violations {
    # Use this to test check_state_test.pm alerting subroutines
    #   - make sure check_state_test.pm is identical to check_state.pm
    #     except for the mailing lists
    #   - expect 21/23 emails (tank and aacccdpt red alerts disabled)
    use snap;
    use comps;
    use snap_format;
    use check_state_test;

    my $test_dir = "/home/malgosia/git/snapshot";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    # Use the test telemetry files with yellow violations
    `cp -f $test_dir/tests/tl_yellow_violations/*.tl $test_dir/`;

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    %h = check_state_test(%h);
}

1;
