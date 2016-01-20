# ************************************************************************* 
# Copyright (c) 2014-2016, SUSE LLC
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
# test employee commands as admin user

#!perl
use 5.012;
use strict;
use warnings;

#use App::CELL::Test::LogToFile;
use App::CELL qw( $CELL $log $meta $site );
use App::Dochazka::CLI qw( $debug_mode );
use App::Dochazka::CLI::Parser qw( process_command );
use App::Dochazka::CLI::Test qw( init_unit );
use App::Dochazka::CLI::Util qw( authenticate_to_server );
use Data::Dumper;
use Test::More;
use Test::Warnings;

$debug_mode = 1;

my ( $cmd, $rv );

$rv = init_unit();
plan skip_all => "init_unit failed with status " . $rv->text unless $rv->ok;

$rv = authenticate_to_server( user => 'root', password => 'immutable', quiet => 1 );
if ( $rv->not_ok and $rv->{'http_status'} =~ m/500 Can\'t connect/ ) {
    plan skip_all => "Can't connect to server";
}

isnt( $meta->MREST_CLI_URI_BASE, undef, 'MREST_CLI_URI_BASE is defined after initialization' );

note( 'Create testing employee with UTF-8 characters' );
$cmd = "PUT employee nick george { \"fullname\" : \"Karel Omáčka\" }";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
ok( $rv->ok );
is( $rv->code, 'DOCHAZKA_CUD_OK' );
is( $rv->payload->{'nick'}, 'george' );
is( $rv->payload->{'fullname'}, "Karel Om\x{e1}\x{10d}ka" );

note( 'EMP=george PROFILE to test UTF-8 handling' );
$cmd = "EMP=george PROFILE";
$rv = process_command( $cmd );
ok( ref( $rv ) eq 'App::CELL::Status' );
ok( $rv->ok );
like( $rv->payload, qr/Full name:    Karel Om\x{e1}\x{10d}ka/ );

done_testing;