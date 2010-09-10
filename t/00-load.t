#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::HashBlue' ) || print "Bail out!
";
}

diag( "Testing WebService::HashBlue $WebService::HashBlue::VERSION, Perl $], $^X" );

unless( $ENV{HASHBLUE_APIKEY} && $ENV{HASHBLUE_EMAIL} )
{
	diag( "Set the environment vars HASHBLUE_APIKEY and HASHBLUE_EMAIL");
	diag( "to run the complete test suite.");
}
