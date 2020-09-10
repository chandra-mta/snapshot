package Time::DayOfYear;

use Carp;

require 5.000;

@ISA = qw(Exporter);
@EXPORT = qw(ydoy2md ymd2doy);

use strict;

use vars qw($VERSION @dtab);

$VERSION = 99.0226;

CONFIG:	{
	@dtab = ( [0,0,31,59,90,120,151,181,212,243,273,304,334],
	          [0,0,31,60,91,121,152,182,213,244,274,305,335] );
}

sub ymd2doy
{
	my ($year, $month, $day) = @_;
	return $dtab[is_leap_year($year)][$month]+$day;
}

sub ydoy2md
{
	my ($year, $day_of_year) = @_;
	my @days = grep { $_ > 0 } map { $day_of_year - $_ } @{$dtab[is_leap_year($year)]};
	return ( $#days, $days[-1] );
}

sub is_leap_year
{
	my ($year) = @_;
	return 0 unless $year % 4 == 0;
	return 1 unless $year % 100 == 0;
	return 0 unless $year % 400 == 0;
	return 1;
}

1;

__DATA__

=head1 NAME

Time::DayOfYear -- convert between (Month,Day) and (Day_of_Year) date formats.

=head1 SYNOPSIS

	use Time::DayOfYear;

	($month_1_to_12, $day_of_month_1_to_31) = ydoy2md($four_digit_year, $day_of_year_1_to_366);
	$day_of_year_1_to_366 = ymd2doy($four_digit_year, $month_1_to_12, $day_of_month_1_to_31);

=head1 DESCRIPTION

DayOfYear converts between (Month,Day) and (Day_of_Year) date formats.
Years should be expressed with four digits: 1998, not 98.
Beware! Input variables are not checked to be valid.

=head1 AUTHOR

Robert Cameron <rcameron@cfa.harvard.edu>
