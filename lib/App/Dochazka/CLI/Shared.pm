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
# Shared routines
package App::Dochazka::CLI::Shared;

use 5.012;
use strict;
use warnings;

use App::CELL qw( $CELL );
use App::Dochazka::CLI qw( $current_emp $debug_mode );
use App::Dochazka::CLI::Util qw( lookup_employee rest_error );
use Data::Dumper;
use Exporter 'import';
use JSON;
use Web::MREST::CLI::UserAgent qw( send_req );




=head1 NAME

App::Dochazka::CLI::Shared - Shared routines




=head1 PACKAGE VARIABLES

=cut

our @EXPORT_OK = qw(
    print_schedule_object
    show_current
);




=head1 FUNCTIONS

The functions in this module are called from handlers.

=cut


=head2 print_schedule_object

Use this function to "print" a schedule object (passed an an argument). The
"printed schedule" (string) is returned.

=cut

sub print_schedule_object {
    my ( $sch ) = @_;
    die "AAGH! Not a schedule object" unless ref( $sch ) eq 'App::Dochazka::Common::Model::Schedule';
    my $ps = '';

    $ps .= "DISABLED | " if $sch->disabled;
    $ps .= "Schedule ID (SID): " . $sch->sid . "\n";
    if ( my $scode = $sch->scode ) {
        $ps .= "DISABLED | " if $sch->disabled;
        $ps .= "Schedule code (scode): " . $scode . "\n";
    }

    # decode the schedule
    my $sch_array = decode_json( $sch->schedule );
    foreach my $entry ( @$sch_array ) {
        $ps .= "DISABLED | " if $sch->disabled;
        # each entry is a hash with properties low_dow, low_time, high_dow, high_time
        $ps .= "[ " . $entry->{'low_dow'} . " " . $entry->{'low_time'} . ", " .
                      $entry->{'high_dow'} . " " . $entry->{'high_time'} . " )\n";
    }

    # remark
    if ( my $remark = $sch->remark ) {
        $ps .= "DISABLED | " if $sch->disabled;
        $ps .= "Remark: " . $sch->remark  . "\n";
    }

    return $ps;
}


=head2 show_current

Given $type (either "priv" or "schedule") and $ts hashref, return
status object.

=cut

sub show_current {
    print "Entering " . __PACKAGE__ . "::show_current\n" if $debug_mode;
    my ( $type, $th ) = @_;

    my $emp_spec = ( $th->{'EMPLOYEE_SPEC'} )
        ? $th->{'EMPLOYEE_SPEC'}
        : $current_emp;
    
    my ( $eid, $nick, $status, $resource );
    if ( $emp_spec->can('eid') ) {
        $eid = $emp_spec->eid;
        $nick = $emp_spec->nick;
        $resource = "$type/self";
    } elsif ( ref( $emp_spec ) eq '' ) {
        $status = lookup_employee( key => $emp_spec );
        return rest_error( $status, "Employee lookup" ) unless $status->ok;
        $eid = $status->payload->{'eid'};
        $nick = $status->payload->{'nick'};
        $resource = "$type/eid/$eid";
    } else {
        die "AGHHAH! bad employee specifier";
    }

    $status = send_req( 'GET', $resource );
    if ( $status->ok ) {
        my $pl = '';
        if ( $type eq 'priv' ) {
            $pl .= "The current privilege level of $nick (EID $eid) is " . $status->payload->{'priv'} . "\n";
        } elsif ( $type eq 'schedule' ) {
            my $sch_obj = App::Dochazka::Common::Model::Schedule->spawn( %{ $status->payload->{'schedule'} } );
            $pl .= print_schedule_object( $sch_obj );
        } else {
            die "AGH! bad type " . $type || "undefined";
        }
        return $CELL->status_ok( 'DOCHAZKA_CLI_NORMAL_COMPLETION', payload => $pl );
    }

    return rest_error( $status, "GET $resource" );
}


1;
