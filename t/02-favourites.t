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

my $favourites = $blue->get_messages;
isnt(ref($favourites), 'HTTP::Response', 'get_messages returned arrayref');


done_testing();
