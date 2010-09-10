#!perl -T

use strict;
use warnings;

use Test::More;

unless ( $ENV{HASHBLUE_APIKEY} && $ENV{HASHBLUE_EMAIL} )
{
    plan( skip_all => "API Authentication details not found" );
}

use_ok( 'WebService::HashBlue' );

my $blue = WebService::HashBlue->new(
	api_key => $ENV{HASHBLUE_APIKEY},
	email   => $ENV{HASHBLUE_EMAIL}
);
ok($blue, 'Constructed new WebService::HashBlue object');

my $messages = $blue->get_messages;
isnt(ref($messages), 'HTTP::Response', 'get_messages returned arrayref');

# This number is a test number supplied by o2 - probably needs removing in the future
my $sent_message = $blue->send_message(
	contact => '4477163544106',
	message => 'Testing WebService::HashBlue'
);
isnt(ref($sent_message), 'HTTP::Response', 'send_message returned response');

my $search_results = $blue->search_messages('blue');
isnt(ref($search_results), 'HTTP::Response', 'search_messages returned response');



done_testing();

