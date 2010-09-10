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

my $contacts = $blue->get_contacts;
isnt(ref($contacts), 'HTTP::Response', 'get_contacts returned arrayref');
if(scalar @$contacts >= 1)
{
	my $contact_messages = $blue->contact_messages($contacts->[0]->{id});
	isnt(ref($contact_messages), 'HTTP::Response', 'contact_messages returned arrayref');
}

done_testing();
