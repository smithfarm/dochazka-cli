# ************************************************************************* 
# Copyright (c) 2014-2015, SUSE LLC
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of SUSE LLC nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# ************************************************************************* 
#
# Interval commands
package App::Dochazka::CLI::Commands::Interval;

use 5.012;
use strict;
use warnings;

use App::CELL qw( $CELL );
use App::Dochazka::CLI qw( $current_emp $debug_mode $prompt_date $prompt_year );
use App::Dochazka::CLI::Util qw( 
    determine_employee
    normalize_date
    normalize_time
    parse_test 
    refresh_current_emp
    rest_error
    truncate_to
);
use Data::Dumper;
use Date::Calc qw( Days_in_Month );
use Exporter 'import';
use JSON;
use Params::Validate qw( :all );
use Text::Table;
use Web::MREST::CLI qw( send_req );




=head1 NAME

App::Dochazka::CLI::Commands::Interval - Interval commands




=head1 PACKAGE VARIABLES

=cut

our %month_map = (
    'jan' => 1,
    'feb' => 2,
    'mar' => 3,
    'apr' => 4,
    'may' => 5,
    'jun' => 6,
    'jul' => 7,
    'aug' => 8,
    'sep' => 9,
    'oct' => 10,
    'nov' => 11,
    'dec' => 12,
);

our @EXPORT_OK = qw( 
    interval_fetch_date
    interval_fetch_date_date1
    interval_fetch_month
    interval_fetch_num_num1
    interval_fetch_promptdate
    interval_new_date_time_date1_time1
    interval_new_time_time1
    interval_new_timerange
);




=head1 FUNCTIONS

The functions in this module are called from the parser when it recognizes a command.


=head2 Command handlers

Functions called from the parser


=head3 interval_new_date_time_date1_time1

    INTERVAL NEW _DATE _TIME _DATE1 _TIME1 _TERM
    INTERVAL NEW _DATE _TIME _HYPHEN _DATE1 _TIME1 _TERM

=cut

sub interval_new_date_time_date1_time1 {
    print "Entering " . __PACKAGE__ . "::interval_new_date_time_date1_time1\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    my $status = _tsrange_from_dates_and_times( $th->{_DATE}, $th->{_DATE1}, $th->{_TIME}, $th->{_TIME1} );
    return $status unless $status->ok;

    return _interval_new( $th->{_TERM}, $status->payload, $th->{_REST} );
}


=head3 interval_new_time_time1

=cut

sub interval_new_time_time1 {
    print "Entering " . __PACKAGE__ . "::interval_new_time_time1\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    my $status = _tsrange_from_dates_and_times( $th->{_DATE}, undef, $th->{_TIME}, $th->{_TIME1} );
    return $status unless $status->ok;

    return _interval_new( $th->{_TERM}, $status->payload, $th->{_REST} );
}


=head3 interval_new_timerange

=cut

sub interval_new_timerange {
    print "Entering " . __PACKAGE__ . "::interval_new_timerange\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    my ( $rt0, $rt1 ) = $th->{_TIMERANGE} =~ m/\A(\d{1,2}:\d{1,2})-(\d{1,2}:\d{1,2})/;
    my $status = _tsrange_from_dates_and_times( $th->{_DATE}, undef, $rt0, $rt1 );
    return $status unless $status->ok;

    print "tsrange: " . $status->payload . "\n" if $debug_mode;

    return _interval_new( $th->{_TERM}, $status->payload, $th->{_REST} );
}


=head3 interval_fetch_date

    INTERVAL _DATE
    EMPLOYEE_SPEC INTERVAL _DATE
    INTERVAL FETCH _DATE
    EMPLOYEE_SPEC INTERVAL FETCH _DATE
    INTERVAL FILLUP _DATE
    EMPLOYEE_SPEC INTERVAL FILLUP _DATE

=cut

sub interval_fetch_date {
    print "Entering " . __PACKAGE__ . "::interval_fetch_date\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    # determine employee
    my $status = determine_employee( $th->{'EMPLOYEE_SPEC'} );
    return $status unless $status->ok;
    my $emp = $status->payload;
    my $eid = $emp->eid;

    # determine date
    my $date = normalize_date( $th->{'_DATE'} );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date;

    # assemble tsrange -- note round paren before lower timestamp
    my $tsr = "( $date 00:00, $date 24:00 )";

    if ( $th->{'FILLUP'} ) {
        # fillup "dry run" - i.e. GET interval/fillup/...
        return _fillup_dry_run( eid => $eid, begin_date => $date, end_date => $date );
    } else {
        return _print_intervals_tsrange( $emp, $tsr );
    }
}


=head3 interval_fetch_date_date1

    INTERVAL _DATE _DATE1
    EMPLOYEE_SPEC INTERVAL _DATE _DATE1
    INTERVAL FETCH _DATE _DATE1
    EMPLOYEE_SPEC INTERVAL FETCH _DATE _DATE1
    INTERVAL FILLUP _DATE _DATE1
    EMPLOYEE_SPEC INTERVAL FILLUP _DATE _DATE1
    INTERVAL _DATE _HYPHEN _DATE1
    EMPLOYEE_SPEC INTERVAL _DATE _HYPHEN _DATE1
    INTERVAL FETCH _DATE _HYPHEN _DATE1
    EMPLOYEE_SPEC INTERVAL FETCH _DATE _HYPHEN _DATE1
    INTERVAL FILLUP _DATE _HYPHEN _DATE1
    EMPLOYEE_SPEC INTERVAL FILLUP _DATE _HYPHEN _DATE1

=cut

sub interval_fetch_date_date1 {
    print "Entering " . __PACKAGE__ . "::interval_fetch_date_date1\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    # determine employee
    my $status = determine_employee( $th->{'EMPLOYEE_SPEC'} );
    return $status unless $status->ok;
    my $emp = $status->payload;
    my $eid = $emp->eid;

    # determine date
    my $date = normalize_date( $th->{'_DATE'} );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date;
    my $date1 = normalize_date( $th->{'_DATE1'} );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date1;

    # assemble tsrange -- note round paren before lower timestamp
    my $tsr = "( $date 00:00, $date1 24:00 )";

    return ( $th->{'FILLUP'} )
        ?  _fillup_dry_run( eid => $eid, begin_date => $date, end_date => $date1 );
        : _print_intervals_tsrange( $emp, $tsr );
}


=head3 interval_fetch_month

    INTERVAL _MONTH [_NUM]
    EMPLOYEE_SPEC INTERVAL _MONTH [_NUM]
    INTERVAL FETCH _MONTH [_NUM]
    EMPLOYEE_SPEC INTERVAL FETCH _MONTH [_NUM]
    INTERVAL FILLUP _MONTH [_NUM]
    EMPLOYEE_SPEC INTERVAL FILLUP _MONTH [_NUM]

=cut

sub interval_fetch_month {
    print "Entering " . __PACKAGE__ . "::interval_fetch_month\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    # determine employee
    my $status = determine_employee( $th->{'EMPLOYEE_SPEC'} );
    return $status unless $status->ok;
    my $emp = $status->payload;
    my $eid = $emp->eid;

    # determine lower and upper bounds
    # - month
    my ( $month ) = $th->{'_MONTH'} =~ m/\A(\S\S\S)/;
    $month = lc $month;
    my $nmonth = $month_map{ $month };
    # - year
    my $year = $th->{'_NUM'} || $prompt_year;
    # - normalize
    my $date = normalize_date( "$year-$nmonth-1"  );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date;
    my $date1 = normalize_date( "$year-$nmonth-" . 
                                Days_in_Month( $year, $nmonth ) );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date1;

    # assemble tsrange -- note round paren before lower timestamp
    my $tsr = "( $date 00:00, $date1 24:00 )";

    return ( $th->{'FILLUP'} )
        ?  _fillup_dry_run( eid => $eid, begin_date => $date, end_date => $date1 );
        :  _print_intervals_tsrange( $emp, $tsr );
}


=head3 interval_fetch_num_num1

    INTERVAL _NUM [_NUM1]
    EMPLOYEE_SPEC INTERVAL _NUM [_NUM1]
    INTERVAL FETCH _NUM [_NUM1]
    EMPLOYEE_SPEC INTERVAL FETCH _NUM [_NUM1]
    INTERVAL FILLUP _NUM [_NUM1]
    EMPLOYEE_SPEC INTERVAL FILLUP _NUM [_NUM1]

=cut

sub interval_fetch_num_num1 {
    print "Entering " . __PACKAGE__ . "::interval_fetch_num_num1\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    # determine employee
    my $status = determine_employee( $th->{'EMPLOYEE_SPEC'} );
    return $status unless $status->ok;
    my $emp = $status->payload;
    my $eid = $emp->eid;

    # determine lower and upper bounds
    # - numeric month
    my $nmonth;
    if ( $th->{'_NUM'} >= 0 and $th->{'_NUM'} <= 12 ) {
        $nmonth = $th->{'_NUM'};
    } else {
        return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' );
    }
    # - year
    my $year = $th->{'_NUM1'} || $prompt_year;
    # - normalize
    my $date = normalize_date( "$year-$nmonth-1"  );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date;
    my $date1 = normalize_date( "$year-$nmonth-" . 
                                Days_in_Month( $year, $nmonth ) );
    return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE' ) unless $date1;

    # assemble tsrange -- note round paren before lower timestamp
    my $tsr = "( $date 00:00, $date1 24:00 )";

    return ( $th->{'FILLUP'} )
        ? _fillup_dry_run( eid => $eid, begin_date => $date, end_date => $date1 );
        : _print_intervals_tsrange( $emp, $tsr );
}


=head3 interval_fetch_promptdate

    INTERVAL
    EMPLOYEE_SPEC INTERVAL
    INTERVAL FETCH
    EMPLOYEE_SPEC INTERVAL FETCH
    INTERVAL FILLUP
    EMPLOYEE_SPEC INTERVAL FILLUP

=cut

sub interval_fetch_promptdate {
    print "Entering " . __PACKAGE__ . "::interval_fetch_promptdate\n" if $debug_mode;
    my ( $ts, $th ) = @_;

    # parse test
    return parse_test( $ts, $th ) if $ts eq 'PARSE_TEST';

    print Dumper( $th ) if $debug_mode;

    # determine employee
    my $status = determine_employee( $th->{'EMPLOYEE_SPEC'} );
    return $status unless $status->ok;
    my $emp = $status->payload;
    my $eid = $emp->eid;

    # assemble tsrange -- note round paren before lower timestamp
    my $tsr = "( $prompt_date 00:00, $prompt_date 24:00 )";

    return ( $th->{'FILLUP'} )
        ? _fillup_dry_run( eid => $eid, begin_date => $prompt_date, end_date => $prompt_date );
        : _print_intervals_tsrange( $emp, $tsr );
}


=head2 Helper functions

Functions called from command handlers


=head3 _interval_new

Takes code, tsrange and, optionally, long_desc. Converts the code into an AID,
sets up and sends the "POST interval/new" REST request, and returns the
resulting status object.

=cut

sub _interval_new {
    my ( $code, $tsrange, $long_desc ) = validate_pos( @_,
        { type => SCALAR },
        { type => SCALAR },
        { type => SCALAR|UNDEF, optional => 1 },
    );

    # get aid from code
    my $status = send_req( 'GET', "activity/code/$code" );
    if ( $status->not_ok ) {
        if ( $status->code eq "DISPATCH_SEARCH_EMPTY" and
             $status->text =~ m/Search over activity with key -\>code equals .+\<- returned nothing/
        ) {
            return $CELL->status_err( 'DOCHAZKA_CLI_WRONG_ACTIVITY', args => [ $code ] );
        }
        return rest_error( $status, "Determine AID from code" ) unless $status->ok;
    }
    my $aid = $status->payload->{'aid'};

    # assemble entity
    my $entity_perl = {
        'aid' => $aid,
        'intvl' => $tsrange,
    };
    $entity_perl->{'long_desc'} = $long_desc if $long_desc;
    my $entity = encode_json $entity_perl;

    # send the request
    $status = send_req( 'POST', "interval/new", $entity );
    if ( $status->not_ok ) {
        # if ... possible future checks for common errors
        # elsif ... other common errors
        return rest_error( $status, "Insert new attendance interval" ) unless $status->ok;
    }

    return $CELL->status_ok( 'DOCHAZKA_CLI_NORMAL_COMPLETION',
        payload => _print_interval( $status->payload ) );
}


=head3 _tsrange_from_dates_and_times

Given two dates and two times, returns a full-fledged tsrange.
If the first date is undef or empty, use the prompt date.
If the second date is undef or empty, use the first date.

=cut

sub _tsrange_from_dates_and_times {
    my ( $d0, $d1, $t0, $t1 ) = @_;

    # normalize dates and times
    BREAK_OUT: {
        my $s = 1;
        my $flagged;

        # normalize_date will replace an undefined or empty date with the prompt date
        if ( $s = normalize_date( $d0 ) ) {
            $d0 = $s;
        } else {
            $flagged = $d0;
        }

        # for the second date, we have to check for undefined/empty-ness ourselves
        $d1 = $d0 unless defined( $d1 ) and length( $d1 ) > 0;

        if ( $s = normalize_date( $d1 ) ) {
            $d1 = $s;
        } else {
            $flagged = $d1;
        }

        if ( $s = normalize_time( $t0 ) ) {
            $t0 = $s;
        } else {
            $flagged = $t0;
        }

        if ( $s = normalize_time( $t1 ) ) {
            $t1 = $s;
        } else {
            $flagged = $t1;
        }

        last BREAK_OUT unless $flagged;
        $flagged = 'undefined' if not defined $flagged;
        return $CELL->status_err( 'DOCHAZKA_CLI_INVALID_DATE_OR_TIME', args => [ $flagged ] );
    }

    return $CELL->status_ok( 'DOCHAZKA_CLI_NORMAL_COMPLETION', payload => "[ $d0 $t0, $d1 $t1 )" );
}

=head3 _print_interval

Given an interval object (blessed or unblessed), construct a string
suitable for on-screen display.

=cut

sub _print_interval {
    my ( $int ) = @_;
    
    # get the activity code from the 'aid' property
    my $status = send_req( 'GET', "activity/aid/" . $int->{'aid'} );
    return rest_error( $status, "Determine activity code from AID" ) unless $status->ok;
    my $code = $status->payload->{'code'};

    # convert the interval into a readable form
    my $intvl = $int->{'intvl'};
    my $iid = $int->{'iid'};

    my $out = '';
    $out .= "Interval IID $iid\n";
    $out .= "$intvl $code";
    $out .= " " . $int->{'long_desc'} if defined( $int->{'long_desc'} );
    $out .= "\n";

    return $out;
}

=head3 _print_intervals_tsrange

Given an employee object and a tsrange, print all matching intervals

=cut

sub _print_intervals_tsrange {
    my ( $emp, $tsr ) = @_;
    my $eid = $emp->eid;
    my $nick = $emp->nick;

    my $status = send_req( 'GET', "interval/eid/$eid/$tsr" );
    return rest_error( $status, "Get intervals for employee $nick (EID $eid) in range $tsr" ) 
        unless $status->ok;

    my $pl = '';
    $pl .= "Attendance intervals of $nick (EID $eid)\n";
    $pl .= "in the range $tsr\n\n";

    my $t = Text::Table->new( 'IID', 'Begin', 'End', 'Code', 'Description' );
    for my $int ( @{ $status->payload } ) {
        $t->add( 
            $int->{'iid'},
            _begin_and_end_from_intvl( $int->{'intvl'} ),
            $int->{'code'},
            truncate_to( $int->{'long_desc'} ),
        );
    }
    $pl .= $t;

    return $CELL->status_ok( 'DOCHAZKA_CLI_NORMAL_COMPLETION', payload => $pl );
}


=head3 _begin_and_end_from_intvl

=cut

sub _begin_and_end_from_intvl {
    my $intvl = shift;

    my ( $d0, $t0, $d1, $t1 ) = $intvl =~ 
        m/(\d{4,4}-\d{2,2}-\d{2,2}).*(\d{2,2}:\d{2,2}):\d{2,2}.*(\d{4,4}-\d{2,2}-\d{2,2}).*(\d{2,2}:\d{2,2}):\d{2,2}/;

    return ( "$d0 $t0", "$d1 $t1" );
}


=head3 _fillup_dry_run

=cut

sub _fillup_dry_run {
    my ( %ARGS ) = validate( @_, {
        eid => { type => SCALAR },
        begin_date => { type => SCALAR },
        end_date => { type => SCALAR },
    } );
    my $status = send_req( 'GET', "interval/fillup/eid/$ARGS{eid}/$ARGS{begin_date}/$ARGS{end_date}" );
    return $status
}


1;
