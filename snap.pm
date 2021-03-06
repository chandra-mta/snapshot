# utilities for chandra snapshot
# BDS May 2001
# last update: Oct 06, 2015  by T.I.

sub get_data {
  my %h;
  # read the ACORN tracelog files
  #my @ftype = qw(ACA CCDM EPHIN EPS PCAD SIM-OTG SI TEL);
  #my $data_dir = '/data/mta/www/MIRROR/Snap/Test';
  my $data_dir = shift(@_);
  my @ftype = @_;
  for ($i = 0; $i <= $#ftype; $i++) {
    my %keep;
    @tlfiles = <$data_dir/chandra$ftype[$i]_*.tl>;
    my $time = 1;
    my $last_time = 0;
    $curr_time = time_now();
  
    foreach $f (@tlfiles) {
      #print "Reading $f\n"; #debug
      open (TLF, $f) or next;
      @msids = split ' ', <TLF>;
      shift @msids;                 # exclude time
      <TLF>;                        # skip second line
  
      while (<TLF>) {
        @vals = split /\t/,$_;
        #map { s/^\s+(.+)\s+$/$1/ } @vals;
        map { s/^\s+// } @vals;
        map { s/\s+$// } @vals;
        $time = shift @vals;
        if ($time >= $last_time && $time <= $curr_time) { 
          $last_time = $time;
          foreach (@msids) { 
            $val = shift @vals;
            if ($val ne "") {
              # save previous HKP27V/I
              if ($_ eq "5HSE202") {
                $h{"5HSE202a"} = $h{"5HSE202"};
                $h{"5EHSE106a"} = $h{"5EHSE106"};
              } # if ($_ eq "5HSE202") {
              $h{$_} = [$time, $val, "", "white"];
              #print "$_ ${$h{$_}}[0] ${$h{$_}}[1] ${$h{$_}}[2]\n"; #debug
              # different msids may have valid value in different files
              $keep{$_} = $f;
            }
          }
        }
      }
    }
    # delete old tlfiles
    #  keep latest file and file where value used came from
    #   (usually the same file)
    pop @tlfiles;
    foreach $f (@tlfiles) {
      my $keep = 0;
      # different msids may have valid value in different files
      foreach $keeper (values %keep) {
        if ($f eq $keeper) { 
          $keep = 1;
          last;
        }
      }
      if ($keep eq 0) { unlink $f; }
    }
  }
  return %h;
}

sub set_status {
  my $stale_time = 900; #data more than this many seconds old is called stale 
  my %inh = @_;
  #my $ref_time = time_now();
  my $ref_time = $inh{OBT}[0];
  foreach $key (keys(%inh)) {
    if ($key eq "KP") {$stale_time = 3600;}
    if ($key eq "FLUXACE") {$stale_time = 1800;}
    if ($key eq "CRM") {$stale_time = 1800;}
    if ($ref_time - $inh{$key}[0] > $stale_time) {
      $inh{"$key"}[2] = "S";
      $inh{"$key"}[3] = "#996677";
    }
  }
  # current data uses current time for reference
  my $ref_time = $inh{UTC}[0];
  #my @curr_msids = qw(FLUXACE FLUACE KP EPHEM_ALT EPHEM_LEG);
  my @curr_msids = qw(FLUXACE KP EPHEM_ALT EPHEM_LEG);
  foreach $key (@curr_msids) {
    if ($ref_time - $inh{$key}[0] > $stale_time) {
      $inh{"$key"}[2] = "S";
      $inh{"$key"}[3] = "#996677";
    }
  }
  # also check for bad data
  #  invalid data 
  # these msids are only valid in eps subformat
  my @eps_data = qw(COSCS107S COSCS128S COSCS129S COSCS130S);

  # !! OK, but if get_data works right the eps_data WAS valid at its time
  #    so may now be stale but not invalid
  #   To do: must compare scs and subformat times.
  #    (and of course, same for norm below)

  if ($inh{COTLRDSF}[1] ne 'EPS') {
    foreach (@eps_data) {
      $inh{$_}[2] = "I";
      $inh{$_}[3] = "#996677";
    }
  }
  # these msids are only valid in norm subformat
  my @norm_data = qw(AOCPESTL);
  if ($inh{COTLRDSF}[1] ne 'NORM') {
    foreach (@norm_data) {
      $inh{$_}[2] = "I";
      $inh{$_}[3] = "#996677";
    }
  }
  return %inh;
}
    
sub time_now {
  use Time::TST_Local;
  my $t1998 = 883612800.0;
  my @now = gmtime();
  return (timegm(@now) - $t1998);
}

sub get_curr {
  # collect current ephemeris, ace, kp, data
  # return current data hash table
  my %h;

  # read the ephemeris file
  #@ephem = split ' ',<EF> if open (EF, '/proj/rac/ops/ephem/gephem.dat');
  @ephem = split ' ',<EF> if open (EF, '/data/mta4/proj/rac/ops/ephem/gephem.dat'); #--- ti 10/06/15
  $h{EPHEM_ALT} = [$ephem[2], $ephem[0], "", "white"];
  $h{EPHEM_LEG} = [$ephem[2], $ephem[1], "", "white"];
  
  # read the ACE flux
  
  #$fluf = "/proj/rac/ops/ACE/fluace.dat";
  #$fluf = "/data/mta4/space_weather/ACE/fluace.dat";
  $fluf = "/data/mta4/proj/rac/ops/ACE/fluace.dat";     #--- ti 10/06/15
  if (open FF, $fluf) {
      @ff = <FF>;
      @fl = split ' ',$ff[-3];
      $fluxace = $fl[11];
      close FF;
  } else { print STDERR "$fluf not found!\n" };

  $h{FLUXACE} = [date2secs($fl[0], $fl[1], $fl[2], $fl[3]), $fl[11], "", "white"];
  #$h{FLUXACE} = [date2secs($fl[0], $fl[1], $fl[2], $fl[3]), $fl[13]*36, "", "white"];
  
  # read the ACIS fluence
  
  #$fluf = "/data/acis25/svirani/ACIS/FLU-MON/ACIS-FLUENCE.dat";
  #if (open FF, $fluf) {
      #@ff = <FF>;
      #@fl = split ' ',$ff[-1];
      ##$fluace = $fl[9];
      #close FF;
  #} else { print STDERR "$fluf not found!\n" };
  
  #$h{FLUACE} = [date2secs($fl[0], $fl[1], $fl[2], $fl[3]), $fl[9], "", "white"];

  # read the CRM fluence - replaces F_ACE in snapshot May 2001
  #####$fluf = "/proj/rac/ops/CRM3/CRMsummary.dat";
  $fluf = "/data/mta4/proj/rac/ops/CRM3/CRMsummary.dat";        #--- ti 10/06/15
  if (open FF, $fluf) {
      @ff = <FF>;
      @fl = split ' ',$ff[-1];
      #$flucrm = $fl[-1];
      close FF;
  } else { print STDERR "$fluf not found!\n" };

  # don't know time here, assume same fluxace for now
  $h{CRM} = [$h{FLUXACE}[0], $fl[-1], "", "white"];

  # read the ACE Kp file
  
  #$kpf = "/proj/rac/ops/ACE/kp.dat";
  $kpf = "/data/mta4/proj/rac/ops/ACE/kp.dat";  #--- ti 10/06/15
  if (open KPF, $kpf) {
      while (<KPF>) { $kp = $_ };
  } else { print STDERR "Cannot read $kpf\n" };
  @kp = split /\s+/, $kp;

  $h{KP} = [date2secs($kp[0], $kp[1], $kp[2], $kp[3]), $kp[8], "", "white"];
  
  return %h;
}

sub date2secs {
  my $t1998 = 883612800.0;
  my ($yr, $mo, $day, $time) = @_;
  my $hr = substr($time, 0, 2);
  my $mn = substr($time, 2, 2);
  #print "test $time $mn $hr $day $mo $yr\n";
  if ($mo > 0) {
    return timegm(0, $mn, $hr, $day, $mo-1, $yr-1900) - $t1998;
  } else {
    return 1;
  }
}

sub numerically { $a <=> $b };

sub check_comm {
  # 22.oct 2003 bds 
  # check comm schedule, if data is not flowing
  #  when it should be, send alert
  # actually this gets called only if data is not flowing,
  #  so send alert if comm is scheduled
  my $lockfile = $_[0];
  #my $schedule = '/pool14/chandra/DSN.schedule';
  my $schedule = '/proj/rac/ops/ephem/dsn_summary.dat';
  #my $schedule = 'DSN.test';
  if (! -s $lockfile) { # if $lockfile already exists, do nothing
    $gmt_sec_now = time_now();
    #print "$gmt_sec_now\n"; #debug
    open(SCH,"<$schedule") || print "Can not open $schedule\n";
    <SCH>;
    <SCH>;
    while ($inline=<SCH>) {
      @line=split(/\s+/,$inline);
      $tstart=($line[10]-1998)*31536000+($line[11]*86400)-86400;
      $tstop=($line[12]-1998)*31536000+($line[13]*86400)-86400;
      $leap_year=2000;
      while ($line[10] > $leap_year) {
        $tstart+=86400;
        $leap_year+=4;
      } #while ($line[10] > $leap_year) {
      $leap_year=2000;
      while ($line[12] > $leap_year) {
        $tstop+=86400;
        $leap_year+=4;
      } #while ($line[12] > $leap_year) {
      #print "$tstart $tstop \n"; # debug
      if ($tstop < $gmt_sec_now) {next;}
      if ($tstart > $gmt_sec_now) {last;}
      #if ($tstop-$gmt_sec_now >= 300 && $gmt_sec_now-$tstart >= 2400) {
      if ($tstop-$gmt_sec_now >= 300 && $gmt_sec_now-$tstart >= 900) {
        open(OUT,">$lockfile");
        #print OUT "Gamera -> Rhodes - no real-time data flowing.\n";
        print OUT "Gamera -> c3po-v - no real-time data flowing.\n";
        print OUT "Comm expected:\n";
        print OUT $inline;
        print OUT "\n";
        print OUT "Last tracelog update (ET):\n";
        @lasttl=`/usr/ucb/ls -lt *tl`;
        print OUT "$lasttl[0]\n";
        close OUT;
        #`cat $lockfile | mailx -s"check_comm" brad\@head.cfa.harvard.edu swolk\@head.cfa.harvard.edu 6172573986\@mobile.mycingular.com 6177214360\@vtext.com`;
        ##`cat $lockfile | mailx -s"check_comm" brad\@head.cfa.harvard.edu swolk\@head.cfa.harvard.edu 6172573986\@mobile.mycingular.com`;
        #`cat $lockfile | mailx -s"check_comm" brad\@head.cfa.harvard.edu`;
        # rewrite in nicer format for sot_lead
        unlink $lockfile;
        open(OUT,">$lockfile");
        #print OUT "Real-time data expected but not received for 3 or more minutes.\n";
        print OUT "Real-time data expected but not received for 15 or more minutes.\n";
        print OUT "Comm expected:\n";
        print OUT "$line[10] $line[0] UT ";
        print OUT "$line[5] $line[6] $line[7] $line[8] $line[9]\n";
        print OUT "\n";
        print OUT "Last tracelog update (ET):\n";
        @tl=split(/\s+/,$lasttl[0]);
        print OUT "$tl[4] $tl[5] $tl[6] $tl[7]\n";
        close OUT;
        #`cat $lockfile | mailx -s"check_comm" brad\@head.cfa.harvard.edu swolk\@head.cfa.harvard.edu`;
        #`cat $lockfile | mailx -s"check_comm" brad\@head.cfa.harvard.edu`;
      } #if ($tstop-$gmt_sec_now >= 300 && $gmt_sec_now-$tstart >= 900) {
    } # while (<SCH>) {
    close SCH;
    return;
  } # if (! -s $lockfile) { 
}

sub time_test {
# 07. jan 04 bds
# check file update time against another file instead of against system time
#  clocks on different machines might not be synced
# Arguments: test_file test_time
# Returns: boolean, has test_file been updated in the past test_time minutes?
  if ($#_ < 1) {
    print "time_test. bad ARGS\n";
    return 1;
  } # if ($#ARGV < 1) {
  $test_file=$_[0];
  $test_time=$_[1]/1440.; # -M is in days
  $comp_file=$test_file.".ttest";
  unless (open(COMP,">$comp_file")) {
    print "Can not open test_time comp file\n";
    return 1;
  }
  print COMP "test_time\n";
  close COMP;
  $comp_update=(-M $comp_file); #debug
  $test_update=(-M $test_file); #debug
  #print "$comp_update $test_update\n"; #debug
  if (((-M $test_file) - (-M $comp_file)) < $test_time) {
    #print "1\n"; #debug
    unlink $comp_file;
    return 1;
  }
  #print "0\n"; #debug
  unlink $comp_file;
  return 0;

} #sub time_test {

1;
