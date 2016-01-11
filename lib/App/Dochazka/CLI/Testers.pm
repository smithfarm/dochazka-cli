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
# Documentation for volunteer testers
#
package App::Dochazka::CLI::Testers;

use 5.012;
use strict;
use warnings;




=head1 NAME

App::Dochazka::CLI::Testers - Documentation for volunteer testers



=head1 PREREQUISITES

Before you start, you will need to complete the following steps.

=head2 Install Docker

For testing purposes, you can use the Dockerized REST server. For this, you
will need to have Docker installed and running:

    zypper in docker
    systemctl start docker.service

=head2 Get and run test drive script

The REST server Docker image depends on the official PostgreSQL image and
must be run with certain parameters. A script is provided to make this
easy. First, download the script:

    wget https://raw.githubusercontent.com/smithfarm/dochazka-rest/master/test-drive.sh

Then run it:

    sh test-drive.sh

When the script completes, you should be able to access the REST server at
L<http://localhost:5000>. (It will display a login prompt - you can ignore it.)

=head2 Add zypper repo and install CLI

Next, add the C<home:smithfarm> zypper repo for your operating system:
L<http://software.opensuse.org/download.html?project=home%3Asmithfarm&package=perl-App-Dochazka-CLI>.

And, finally, install the CLI:

    zypper install perl-App-Dochazka-CLI

=head2 Verify success

Provided you have successfully completed all of the above steps, you should
be able to start the CLI and login as "root" with password "immutable":

    $ dochazka-cli -u root -p immutable
    Loading configuration files from
    /usr/lib/perl5/vendor_perl/5.18.2/auto/share/dist/App-Dochazka-CLI
    Cookie jar: /root/.cookies.txt
    URI base http://localhost:5000 set from site configuration
    Authenticating to server at http://localhost:5000 as user root
    Server is alive
    Dochazka(2016-01-12) root ADMIN>

Congratulations! You have passed the first test.

=cut

1;
