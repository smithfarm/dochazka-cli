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
# Documentation for volunteer testers
#
package App::Dochazka::CLI::Testers;

use 5.012;
use strict;
use warnings;




=head1 NAME

App::Dochazka::CLI::Testers - Documentation for volunteer testers



=head1 PREREQUISITES


=head2 Add zypper repo

Add the C<home:smithfarm> zypper repo for your operating system:
L<http://software.opensuse.org/download.html?project=home%3Asmithfarm&package=perl-App-Dochazka-CLI>.


=head2 Server installation

Before you start, you will need to install and set up PostgreSQL and the
Dochazka REST server. There are two ways to accomplish this:
the Docker way and the "traditional" way.

L<"The Docker way"> is arguably simpler, because you don't install as many
packages and there is little or no setup work involved. However, quite a
lot of data (on the order of hundreds of MB) will be downloaded from Docker
Hub. (To handle this, it may be a good idea to put C</var/lib/docker> on a
separate partition.)

L<"The traditional way"> is to install and configure PostgreSQL and the
Dochazka REST server in your testing environment. This is somewhat more
complicated and involves installing and operating a PostgreSQL server on
the machine where you will be running the tests.

Both ways are described below.

=head3 The Docker way

Complete the steps described below:

=over

=item Install Docker

For testing purposes, you can use the Dockerized REST server. For this, you
will need to have Docker installed and running:

    zypper install docker
    systemctl start docker.service

=item Get and run test drive script

The REST server Docker image depends on the official PostgreSQL image and
must be run with certain parameters. A script is provided to make this
easy. Download and run the script:

    wget https://raw.githubusercontent.com/smithfarm/dochazka-rest/master/test-drive.sh
    sh test-drive.sh

If you have never run Docker containers before, you may be surprised that
the script downloads quite a lot of data from Docker Hub. The script should
complete without any error messages.

=item Web browser test

When the C<test-drive.sh> script completes, you should be able to access
the REST server by pointing your browser at L<http://localhost:5000>. At
the login dialog, enter username "demo" and password "demo".

=back


=head3 The traditional way

This way involves taking the same steps as if you were installing a
production Dochazka server.

=over

=item Install server packages

The traditional way assumes that you have the PostgreSQL and Dochazka REST
server packages installed:

    zypper install postgresql postgresql-server postgresql-contrib 
    zypper install perl-App-Dochazka-REST 

=item PostgreSQL setup

Follow the instructions at
L<https://metacpan.org/pod/App::Dochazka::REST::Guide#PostgreSQL-setup>.

=item Site configuration

Follow the instructions at
L<https://metacpan.org/pod/App::Dochazka::REST::Guide#Site-configuration>.

=item Database initialization

Follow the instructions at
L<https://metacpan.org/pod/App::Dochazka::REST::Guide#Database-initialization>.

=item Web browser test

After completing the above, you should be able to access the REST server by
pointing your browser at L<http://localhost:5000>. At the login dialog,
enter username "demo" and password "demo".

=back


=head2 Install Dochazka CLI client

Now that the server part is working, install the CLI:

    zypper install perl-App-Dochazka-CLI

You should now be able to start the CLI and login as "demo" with password
"demo":

    $ dochazka-cli -u demo -p demo
    Loading configuration files from
    /usr/lib/perl5/vendor_perl/5.18.2/auto/share/dist/App-Dochazka-CLI
    Cookie jar: /root/.cookies.txt
    URI base http://localhost:5000 set from site configuration
    Authenticating to server at http://localhost:5000 as user root
    Server is alive
    Dochazka(2016-01-12) demo PASSERBY>

Exit the CLI by issuing the C<exit> command:

    Dochazka(2016-01-12) demo PASSERBY> exit
    $

Congratulations! You have passed the first test.


=head1 SESSION 1: CREATE AN EMPLOYEE

=head2 Try with insufficient privileges

To create an employee, you will need to be logged in as an administrator.
The "demo" employee is not an administrator, but let's try anyway. First,
log in according to L<"Verify success">, above. Then, issue the C<employee
list> command:

    Dochazka(2016-01-12) demo PASSERBY> employee list
    *** Anomaly detected ***
    Status:      403 Forbidden
    Explanation: ACL check failed for resource employee/list/?:priv (ERR)

This output indicates that the REST server returned a C<403 Forbidden> error,
which is to be expected because the C<demo> employee has insufficient
privileges.

Next, try to create an employee:

    Dochazka(2016-01-12) demo PASSERBY> PUT employee nick george { "fullname" : "King George III" }
    HTTP status: 403 Forbidden
    Non-suppressed headers: {
      'X-Web-Machine-Trace' => 'b13,b12,b11,b10,b9,b8,b7'
    }
    Response:
    {
       "payload" : {
          "http_code" : 403,
          "uri_path" : "employee/nick/george",
          "permanent" : true,
          "found_in" : {
             "file" : "/usr/lib/perl5/vendor_perl/5.22.0/App/Dochazka/REST/Auth.pm",
             "package" : "App::Dochazka::REST::Auth",
             "line" : 431
          },
          "resource_name" : "employee/nick/:nick",
          "http_method" : "PUT"
       },
       "text" : "ACL check failed for resource employee/nick/:nick",
       "level" : "ERR",
       "code" : "DISPATCH_ACL_CHECK_FAILED"
    }

Here, the error is the same C<403 Forbidden> but the output is more detailed.
This is because we used a special type of command that is ordinarily only
used to test the REST API.

=head2 Log in as root

For the rest of this session, we will be logged in as the C<root> employee, 
which has a special status in that it is created when the database is
initialized and it is difficult or impossible to delete. In a freshly
initialized database, the C<root> employee's password is "immutable".

The username and password need not be specified on the command line.
Try it this way:

    $ dochazka-cli
    Loading configuration files from /usr/lib/perl5/vendor_perl/5.18.2/auto/share/dist/App-Dochazka-CLI
    Cookie jar: /root/.cookies.txt
    URI base http://localhost:5000 set from site configuration
    Username: root
    Authenticating to server at http://localhost:5000 as user root
    Password: 
    Server is alive
    Dochazka(2016-01-12) root ADMIN>

=head2 List employees

A list of all employees in the database can be obtained using the C<employee
list> command, which is documented at L<App::Dochazka::CLI::Guide|"Get list of
employees">:

    Dochazka(2016-01-12) root ADMIN> employee list

    List of employees with priv level ->all<-
        demo
        root

Actually, there is no priv level "all" - this just means that all employees are
listed, regardless of their priv level.

You can also try listing employees by priv level as per the documentation.

=head2 Create an employee

At the moment there is no CLI command to create a new employee. Hence we use
the REST API testing command as described in
L<App::Dochazka::CLI::Guide|"Create a new employee">:

    Dochazka(2016-01-12) root ADMIN> PUT employee nick george { "fullname" : "King George III" }
    HTTP status: 200 OK
    Non-suppressed headers: {
      'X-Web-Machine-Trace' => 'b13,b12,b11,b10,b9,b8,b7,b6,b5,b4,b3,c3,c4,d4,e5,f6,g7,g8,h10,i12,l13,m16,n16,o16,o14,p11,o20,o18,o18b'
    }
    Response:
    {
       "code" : "DOCHAZKA_CUD_OK",
       "count" : 1,
       "payload" : {
          "email" : null,
          "remark" : null,
          "eid" : 3,
          "passhash" : null,
          "supervisor" : null,
          "sec_id" : null,
          "salt" : null,
          "nick" : "george",
          "fullname" : "King George III"
       },
       "text" : "DOCHAZKA_CUD_OK",
       "DBI_return_value" : 1,
       "level" : "OK"
    }

=head2 Employee profile

The properties, or attributes, of the C<employee> class can be seen in the
output of the previous command (under "payload"). A more comfortable way to
display the properties of any employee is the C<employee profile> command:

    Dochazka(2016-01-12) root ADMIN> employee profile

    Full name:    Root Immutable
    Nick:         root
    Email:        root@site.org
    Secondary ID: (not set)
    Dochazka EID: 1
    Reports to:   (not set)

In this form, it displays the profile of the logged-in employee. To show the
profile of a different employee, use this form:

    Dochazka(2016-01-12) root ADMIN> emp=demo profile

    Full name:    Demo Employee
    Nick:         demo
    Email:        demo@dochazka.site
    Secondary ID: (not set)
    Dochazka EID: 2
    Reports to:   (not set)

Here, the "emp=demo" is an employee spec. This is explained in
L<App::Dochazka::CLI::Guide/"Specify an employee">.

Finally, try various combinations of the following commands to get
information about the new employee you just created:

    employee list
    employee profile
    emp=... profile
    nick=... profile
    eid=... profile

=cut

1;
