# ************************************************************************* 
# Copyright (c) 2014, SUSE LLC
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
# test employee commands as a passerby

#!perl
use 5.012;
use strict;
use warnings FATAL => 'all';

use App::Dochazka::CLI::Parser qw( process_command );
use App::Dochazka::CLI::Util qw( authenticate_to_server init_cli_client );
use Data::Dumper;
use Test::More;

my ( $cmd, $rv );

$rv = init_cli_client();
diag( Dumper $rv ) unless $rv->ok;

$rv = authenticate_to_server( user => 'demo', password => 'demo', quiet => 1 );
if ( $rv->not_ok and $rv->{'http_status'} =~ m/500 Can\'t connect/ ) {
    plan skip_all => "Can't connect to server";
}

$cmd = "EMPLOYEE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
is( $rv->level, 'OK' );
like( $rv->payload, qr/Nick:\s+demo/ );
like( $rv->payload, qr/Dochazka EID:\s+\d+/ );
like( $rv->payload, qr/Privlevel:\s+passerby/ );

$cmd = "EMPLOYEE PROFILE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
is( $rv->level, 'OK' );
like( $rv->payload, qr/Nick:\s+demo/ );
like( $rv->payload, qr/Dochazka EID:\s+\d+/ );
like( $rv->payload, qr/Privlevel:\s+passerby/ );

# EMPLOYEE_SPEC on self always works
$cmd = "EMPLOYEE=demo PROFILE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
is( $rv->level, 'OK' );
like( $rv->payload, qr/Nick:\s+demo/ );
like( $rv->payload, qr/Dochazka EID:\s+\d+/ );
like( $rv->payload, qr/Privlevel:\s+passerby/ );

# EMPLOYEE_SPEC on a different employee => 403
$cmd = "EMPLOYEE=absent PROFILE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
is( $rv->level, 'ERR' );
is( $rv->{'http_status'}, '403 Forbidden' );

# EMPLOYEE_SPEC on non-existent employee => 403
$cmd = "EMPLOYEE=999999 PROFILE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
is( $rv->level, 'ERR' );
is( $rv->code, 'REST_ERROR' );
like( $rv->payload, qr/DISPATCH_KEEP_TO_YOURSELF/ );
is( $rv->{'http_status'}, '403 Forbidden' );

done_testing;
