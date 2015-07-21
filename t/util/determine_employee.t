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
# Tests for Util.pm functions:
# + determine_employee
# + lookup_employee
#

#!perl
use 5.012;
use strict;
use warnings FATAL => 'all';

use App::CELL qw( $meta $site );
use App::Dochazka::CLI qw( $current_emp $current_priv );
use App::Dochazka::CLI::Util qw( 
    authenticate_to_server 
    determine_employee
    init_cli_client 
    lookup_employee
);
use Data::Dumper;
use Test::More;
use Test::Fatal;

my ( $status, $rv, $rv_type );

note( 'init and auth' );
init_cli_client();
$rv = authenticate_to_server( user => 'root', password => 'immutable', quiet => 1 );
$rv_type = ref( $rv );
if ( $rv_type ne 'App::CELL::Status' or $rv->not_ok ) {
    if ( $rv->{'http_status'} =~ m/500 Can\'t connect/ ) {
        plan skip_all => "Can't connect to server";
    } else {
        diag "authenticate_to_server returned unexpected status:";
        diag( Dumper $rv );
        BAIL_OUT(0);
    }
}
is( $rv->code, 'DOCHAZKA_CLI_AUTHENTICATION_OK' );

note( 'determine_employee with no argument' );
$status = determine_employee();
is( $status->level, 'OK' );
is( $status->code, 'EMPLOYEE_LOOKUP' ); 
is( ref( $status->payload ), 'App::Dochazka::Common::Model::Employee' );
is( $status->payload->nick, 'root' );

note( 'determine_employee with nick=demo' );
$status = determine_employee( 'nick=demo' );
is( $status->level, 'OK' );
is( $status->code, 'EMPLOYEE_LOOKUP' ); 
is( ref( $status->payload ), 'App::Dochazka::Common::Model::Employee' );
is( $status->payload->nick, 'demo' );
my $demo_eid = $status->payload->eid;
ok( $demo_eid > 1 );

note( 'determine_employee with eid=$demo_eid' );
$status = determine_employee( "eid=$demo_eid" );
is( $status->level, 'OK' );
is( $status->code, 'EMPLOYEE_LOOKUP' ); 
is( ref( $status->payload ), 'App::Dochazka::Common::Model::Employee' );
is( $status->payload->nick, 'demo' );
is( $status->payload->eid, $demo_eid );

note( 'determine_employee with employee=worker' );
$status = determine_employee( "employee=worker" );
is( $status->level, 'OK' );
is( $status->code, 'EMPLOYEE_LOOKUP' ); 
is( ref( $status->payload ), 'App::Dochazka::Common::Model::Employee' );
is( $status->payload->nick, 'worker' );

note( 'lookup_employee with no argument' );
like( exception { lookup_employee(); }, qr/0 parameters were passed to App::Dochazka::CLI::Util::lookup_employee but 1 was expected/, 'dies with expected message' );

note( 'lookup_employee with bogus argument Perl Encyclopedia' );
like( exception { lookup_employee( 'Perl Encyclopedia' ); }, qr/AH! Not an EMPLOYEE_SPEC/, 'dies with expected message' );

note( 'lookup_employee with bogus argument Perl=Encyclopedia' );
like( exception { lookup_employee( 'Perl=Encyclopedia' ); }, qr/AAAHAAAHHH!!! Invalid employee lookup key Perl/, 'dies with expected message' );

note( 'lookup_employee with proper argument EMPLOYEE=perlencyclopedia' );
$status = determine_employee( 'EMPLOYEE=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with proper argument empl=perlencyclopedia' );
$status = determine_employee( 'empl=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with proper argument NICK=perlencyclopedia' );
$status = determine_employee( 'NICK=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with proper argument nickers=perlencyclopedia' );
$status = determine_employee( 'nickers=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with proper argument sec_id=perlencyclopedia' );
$status = determine_employee( 'sec_id=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with proper argument eid=perlencyclopedia' );
$status = determine_employee( 'eid=perlencyclopedia' );
is( ref( $status ), 'App::CELL::Status' );

note( 'lookup_employee with bogus argument eip=Encyclopedia' );
like( exception { lookup_employee( 'eip=Encyclopedia' ); }, qr/AAAHAAAHHH!!! Invalid employee lookup key eip/, 'dies with expected message' );



done_testing;
