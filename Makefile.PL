use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'WebService::HashBlue',
	AUTHOR              => q{Squeeks <squeek@cpan.org>},
	VERSION_FROM        => 'lib/WebService/HashBlue.pm',
	ABSTRACT_FROM       => 'lib/WebService/HashBlue.pm',
	($ExtUtils::MakeMaker::VERSION >= 6.3002
		? ('LICENSE'=> 'perl')
		: ()),

	PREREQ_PM => {
		'Test::More'    => 0.88,
		'Crypt::SSLeay' => 0,
		'LWP'           => 0,
		'URI'           => 0,
		'JSON'          => 2.00
	},

	MIN_PERL_VERSION => '5.008',
	

	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'WebService-HashBlue-*' },
);
