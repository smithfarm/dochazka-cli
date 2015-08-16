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
# Token map
#
package App::Dochazka::CLI::TokenMap;

use 5.012;
use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw( $regex_map );



=head1 NAME

App::Dochazka::CLI::TokenMap - Token map



=head1 PACKAGE VARIABLES

=over

=item C<< $regex_map >>

Maps tokens to regular expression "strings". These strings are just the
"business end" - the final regular expression is generated from each string in
L<App::Dochazka::CLI::Parser>. 

Whatever information you need to get out of the token needs to be in
parentheses. If the token is just a reserved word from which no information
need be extracted, just put the entire thing in parentheses. 

Note that the regex comparison that takes place in
L<App::Dochazka::CLI::Parser> uses the 'i' modifier for a case-insensitive
comparison.

=back

=cut

our $regex_map = { 
#    ACTIVE    => '(active)',
    ACTIVITY  => '(activi\S*)',
    ADD       => '(add\S*)',
#    ADMIN     => '(adm\S*)',
    AID       => '(aid\S*)',
    ALL       => '(all\S*)',
#    APRIL     => '(apr\S*)',
#    AUGUST    => '(aug\S*)',
    BUGREPORT => '(bug\S*)',
    CLEAR     => '(cle\S*)',
    CODE      => '(cod\S*)',
    COMMIT    => '(com\S*)',
    COOKIEJAR => '(coo\S*)',
    CORE      => '(cor\S*)',
    COUNT     => '(cou\S*)',
    CURRENT   => '(cur\S*)',
    DATE      => '(dat\S*)',
    DBSTATUS  => '(dbs\S*)',
#    DECEMBER  => '(dec\S*)',
    DELETE    => '(del\S*)',
    DISABLED  => '(dis\S*)',
    DOCU      => '(doc\S*)',
    DUMP      => '(dum\S*)',
    ECHO      => '(ech\S*)',
    EFFECTIVE => '(eff\S*)',
    EID       => '(eid\S*)',
    EMPLOYEE  => '(emp[^\s=]*)',
    EMPLOYEE_SPEC => '^((emp|sec|nic|eid)[^\s=]*=[%[:alnum:]_][%[:alnum:]_-]*)',
    EXIT      => '(((exi)|(qui)|(\\\\q))\S*)',
#    FEBRUARY  => '(feb\S*)',
    FETCH     => '(fet\S*)',
    FILLUP    => '(fil\S*)',
    FORBIDDEN => '(for\S*)',
#    FRIDAY     => '(fri\S*)',   RESERVED BY _DOW
    FULLNAME  => '(ful\S*)',
    GET       => '(get\S*)',
    HISTORY   => '(his\S*)',
    HOLIDAY   => '(hol\S*)',
    HTML      => '(htm\S*)',
    IID       => '(iid\S*)',
    IMPORT    => '(imp\S*)',
#    INACTIVE  => '(ina\S*)',
    INSERT    => '(ins\S*)',
    INTERVAL  => '(int\S*)',
#    JANUARY   => '(jan\S*)',
#    JULY      => '(jul\S*)',
#    JUNE      => '(jun\S*)',
    LDAP      => '(lda\S*)',
    LID       => '(lid\S*)',
    LIST      => '(lis\S*)',
    LOCK      => '(loc\S*)',
#    MARCH     => '(mar\S*)',
#    MAY       => '(may\S*)',
    MEMORY    => '(mem\S*)',
    META      => '(met\S*)',
#    MONDAY     => '(mon\S*)',   RESERVED BY _DOW
    NEW       => '(new\S*)',
    NICK      => '(nic\S*)',
    NOOP      => '(noo\S*)',
#    NOVEMBER  => '(nov\S*)',
#    OCTOBER   => '(oct\S*)',
    PARAM     => '(par\S*)',
#    PASSERBY  => '(passe\S*)',
    PASSWORD  => '(passw\S*)',
    PHID      => '(phi\S*)',
    PHISTORY_SPEC => '^phi[^\s=]*=(\d+)',
    POD       => '(pod\S*)',
    POST      => '(pos\S*)',
    PRIV      => '(pri\S*)',
    PRIV_SPEC  => '((active)|(adm\S*)|(ina\S*)|(passe\S*))',
    PROFILE   => '(prof\S*)',
    PROMPT    => '(prom\S*)',
    PUT       => '(put\S*)',
    REMARK    => '(rem\S*)',
#    SATURDAY    => '(sat\S*)',  RESERVED BY _DOW
    SCHEDULE  => '(sch\S*)',
    SCHEDULE_SPEC => '^((sco|sid)[^\s=]*=[%[:alnum:]_][%[:alnum:]_-]*)',
    SCODE     => '(sco\S*)',
    SEARCH    => '(sea\S*)',
    SEC_ID    => '(sec\S*)',
    SELF      => '(sel\S*)',
#    SEPTEMBER => '(sep\S*)',
    SESSION   => '(ses\S*)',
    SET       => '(set\S*)',
    SHID      => '(shi\S*)',
    SHISTORY_SPEC => '^shi[^\s=]*=(\d+)',
    SHOW      => '(sho\S*)',
    SID       => '(sid\S*)',
    SITE      => '(sit\S*)',
#    SUNDAY    => '(sun\S*)',  RESERVED BY _DOW
    SUMMARY   => '(sum\S*)',
    SUPERVISOR => '(sup\S*)',
    TEAM      => '(tea\S*)',
    TEXT      => '(tex\S*)',
#    THURSDAY    => '(thu\S*)',  RESERVED BY _DOW
#    TODAY       => '(tod\S*)',  RESERVED BY _TIMESTAMP
#    TOMORROW    => '(tom\S*)',  RESERVED BY _TIMESTAMP
#    TUESDAY    => '(tue\S*)',  RESERVED BY _DOW
    VERSION   => '(ver\S*)',
#    WEDNESDAY    => '(wed\S*)',  RESERVED BY _DOW
    WHOAMI    => '(who\S*)',
#    YESTERDAY => '(yes\S*)',  RESERVED BY _TIMESTAMP
    _DATE     => '(((\d{2,4}-)?\d{1,2}-\d{1,2})|(tod\S*)|(tom\S*)|(yes\S*)|([\+\-]\d{1,3}))',
    _DOCU     => '(([^\{\s]+)|(\"[^\"]*\"))',
    _DOW      => '((mon\S*)|(tue\S*)|(wed\S*)|(thu\S*)|(fri\S*)|(sat\S*)|(sun\S*))',
    _HYPHEN   => '(-)',
    _JSON     => '(\{[^\{]*\})',
    _MONTH    => '((jan\S*)|(feb\S*)|(mar\S*)|(apr\S*)|(may\S*)|(jun\S*)|(jul\S*)|(aug\S*)|(sep\S*)|(oct\S*)|(nov\S*)|(dec\S*))',
    _NUM      => '([123456789][0123456789]*)',
    _TERM     => '([%[:alnum:]_][%[:alnum:]_-]*)',
    _TIME     => '(\d{1,2}:\d{1,2}(:\d{1,2})?)',
    _TIMERANGE => '(\d{1,2}:\d{1,2}-\d{1,2}:\d{1,2})',
    _TIMESTAMP => '(\"?(\d{2,4}-)?\d{1,2}-\d{1,2}(\s+\d{1,2}:\d{1,2}(:\d{1,2})?)?\"?)',
    _TIMESTAMPDEPR => '(\"?((?<dp>((\d{2,4}-)?\d{1,2}-\d{1,2})|(tod\S*)|(tom\S*)|(yes\S*))\s+)?(?<tp>\d{1,2}:\d{1,2}(:\d{1,2})?)\"?)',
    _TSRANGE  => '([\[\(][^\[\(\]\)]*,[^\[\(]*[\]\)])',
};

1;
