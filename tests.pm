# tests for chandra snapshot
# MS Sep 2020
# last update:


sub test_snap_get_data {
    use snap;
    my @test_vals;

    # Use telemetry with no violations
    my $tl_dir = "/home/malgosia/git/snapshot/tests/tl_no_violations";
    my @tlfiles = ("$tl_dir/chandraIRU_00716605019.35.tl", "$tl_dir/chandraTEL_00716471275.22.tl");
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    my %h = get_data($test_dir, @ftype);

    foreach my $tlfile (@tlfiles) {
        open FILE, "<$tlfile" or die "opening $tlfile: $!\n";
        $last = $_ while <FILE>;
        close FILE;
        @vals = split ' ', $last;
        push @test_vals, $vals[3];
    }

    if ($test_vals[0] == $h{AIRU2G1I}[1] && $test_vals[1] == $h{'4OBAVTMF'}[1]) {
        print "Test test_snap_get_data() passed.\n";
    } else {
        print "Test test_snap_get_data() passed.\n";
    }
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

    # Use telemetry with no violations
    my %h = get_data("${test_dir}/tl_no_violations", @ftype);
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

    # Delete all .*wait and .*alert files
    my @aux_files = glob("${test_dir}/.*wait ${test_dir}/.*alert");
    for my $aux_file (@aux_files) {
        unlink $aux_file or warn "Could not unlink $aux_file: $!";
    }

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    my $nalerts = 0;
    for ($i = 0; $i < 20; $i++) {
        %h = check_state(%h);
        my @files = glob("${test_dir}/.*alert");
        $n = @files;
        $nalerts = $nalerts + $n;
    }
    
    if ($nalerts == 0) {
        print "Test of no violations passed, no alerts sent out.\n";
    } else {
        print "Test of no violations failed.\n";
    }
}


sub test_check_state_test_send_msid_alert {
    # Use this to test check_state_test.pm alerting subroutines
    #   - make sure check_state_test.pm is identical to check_state.pm
    #     except for the mailing lists
    #   - expect test email for $msid
    use snap;
    use comps;
    use snap_format;
    use check_state_test;

    my $msid = shift(@_);
    my $nwait = shift(@_);
    my $afile = shift(@_);

    my $test_dir = "/home/malgosia/git/snapshot";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    # Use the test telemetry files with violations
    `cp -f $test_dir/tests/${msid}_violation/*.tl $test_dir/`;

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    for ($i = 0; $i < $nwait; $i++) {
        # Delete all .*wait and .*alert files
        if ($i == 0) {
            my @aux_files = glob("${test_dir}/.*wait ${test_dir}/.*alert");
            for my $aux_file (@aux_files) {
                unlink $aux_file or warn "Could not unlink $aux_file: $!";
            }
        }
        %h = check_state(%h);
    }
        
    if (-s $afile) {
        print "$msid alert test passed but confirm that an email was received\n";
    } else {
        print "$msid alert test failed.\n";
    }
}

sub test_check_state_test_rearm_msid {
    # Use this to test check_state_test.pm alerting subroutines
    #   - make sure check_state_test.pm is identical to check_state.pm
    #     except for the mailing lists
    #   - expect 0/0 emails
    #   - runs after a violation test so .*alert file exists
    use snap;
    use comps;
    use snap_format;
    use check_state_test;

    my $msid = shift(@_);
    my $nwait = shift(@_);
    my $afile = shift(@_);

    my $test_dir = "/home/malgosia/git/snapshot";
    my @ftype = qw(ACA CCDM EPHIN EPS PCAD IRU SIM-OTG SI TEL EPS-SFMT NORM-SFMT);

    # Use the test telemetry files with no violations
    `cp -f $test_dir/tests/tl_no_violations/*.tl $test_dir/`;

    my %h = get_data($test_dir, @ftype);
    %h = do_comps(%h);
    %h = set_status(%h, get_curr(%h));

    my $nalerts = 0;
    for ($i = 0; $i < $nwait; $i++) {
        %h = check_state(%h);
    }

    if (-s $afile) {
        print "Test of rearming $msid alert failed.\n";
    } else {
        print "Test of rearming $msid alert passed, .*alert file deleted.\n";
    }
}

1;
