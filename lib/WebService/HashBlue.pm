package WebService::HashBlue;

use strict;
use warnings;

use 5.008;

use LWP::UserAgent;
use JSON;
use URI;

my $default_host = 'https://api.hashblue.apigee.com';

=head1 NAME

WebService::HashBlue - Interact with Telefonica/o2's #blue service

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use WebService::HashBlue;
    
    my $blue = WebService::HashBlue->new(api_key => 'asdfm12312p' email => 'squeek@cpan.org');
    my $messages = $blue->get_messages;
    my $response = $blue->search_messages('#perl');

=head1 METHODS

=head2 new(email => $email, api_key => $api_key)

Creates a new L<WebService::HashBlue> object. Both email address and API key are mandatory.

=cut

sub new
{
	my($class, %opts) = @_;

	die('Both API key and Email need to be specified!') unless($opts{email} && $opts{api_key});

	my $self = {
		ua      => LWP::UserAgent->new,
		uri     => URI->new($opts{host} || $default_host),
		email   => $opts{email},
		api_key => $opts{api_key}
	};

	return bless $self;
}

=head2 Messaging

=head3 get_messages

Returns an array containing all messages.

=cut

sub get_messages
{
	my $self = shift;
	return $self->_request( task => 'messages', method => 'GET' );
}

=head3 search_nessages($query)

Search through all messages.

=cut

sub search_messages
{
	my($self, $query) = @_;
	die "No search query specified!" unless $query;
	return $self->_request( task => 'messages', method => 'GET', params => { 'q' => $query } );
}

=head3 send_message(contact => $number, message => $message)

Send an SMS to a specified number. Numbers need to be formatted with country code and no prefixing zeros or plus sign, 
for example C<+44 07700 900492> should be called as C<447700900492>. Messages should contain up to 
160 characters, anything longer is truncated.

=cut

sub send_message
{
	my($self, %opts) = @_;

	$opts{contact} =~s/[^\d+]//g;
	my $message    = substr $opts{message}, 0, 160;

	return $self->_request(
		task   => 'messages',
		method => 'POST',
		params => {
			'message[contact_msisdn]' => $opts{contact},
			'message[content]'        => $message
		}
	);
}

=head3 delete_message

Marks a specific message for deletion. Messages aren't actually delete, just marked. Message ID is mandatory.

=cut

sub delete_message
{
	my($self, $message_id) = @_;
	die "Message ID not supplied!" unless $message_id;
	return $self->_request(
		task   => 'messages/'.$message_id,
		method => 'DELETE'
	);

}

=head3 deleted_messages

Returns an arrayref containing all the messages that were  marked as deleted.

=cut

sub deleted_messages
{
	my $self = shift;
	return $self->_request( task => 'deleted_messages', method => 'GET' );	
}

=head2 Favourites

=head3 get_favourites

Returns an arrayref containing all the favourites added by the user.

=cut

sub get_favourites
{
	my $self = shift;
	return $self->_request( task => 'favourites', method => 'GET' );
}

=head3 add_favourite($message_id)

Add a message as a favourite. Message ID must be supplied.

=cut

sub add_favourite
{
	my($self, $message_id)  = @_;

	die 'Message ID not specified' unless $message_id;

	return $self->_request(
		task   => 'favourites',
		method => 'POST',
		params => { 'id' => $message_id }
	);
}

=head3 remove_favourite($message_id)

Unmark a message as favourite. Message ID must be supplied.

=cut

sub remove_favourite
{
	my($self, $message_id) = @_;

	return $self->_request(
		task   => 'favourites/'.$message_id,
		method => 'DELETE'
	);

}

=head2 Contacts

=head3 get_contacts

Returns an arrayref of all the contacts kept by the user.

=cut

sub get_contacts
{
	my $self = shift;
	return $self->_request( task => 'contacts', method => 'GET' );
}

=head3 contact_messages($contact_id)

Retrieves all messages for a given contact.

=cut

sub contact_messages
{
	my($self, $contact_id)  = @_;
	die "Contact ID not specified!" unless $contact_id;
	return $self->_request( task => 'contacts/'.$contact_id.'/messages', method => 'GET' );	
}

=head3 delete_contact_messages($contact_id)

Deletes all messages by a specified contact ID.

=cut

sub delete_contact_messages
{
	my($self, $contact_id) = @_;
	die "Contact ID not specified!" unless $contact_id;
	return $self->_request(
		task   => 'contacts/'.$contact_id.'/messages',
		method => 'DELETE'
	);

}


# _request(task => $task, method => 'POST', params => {'message[contact_msisdn]' => '38921111'})
# Handles all the HTTPS requests. 
sub _request
{
	my($self, %opts) = @_;

	my $uri = $self->{uri}->clone;
	$uri->path('/subscribers/'.$self->{api_key}.'/'.$opts{task}.'.json');
	my $url = $uri->as_string;
	$uri->query_form($opts{params});

	my $req;
	if($opts{method} eq 'GET')
	{
		$req = HTTP::Request->new('GET' => $uri->as_string);
	}
	elsif($opts{method} eq 'DELETE')
	{
		$req = HTTP::Request->new('DELETE' => $url);
	}
	elsif($opts{method} eq 'POST')
	{
		$req = HTTP::Request->new('POST', $url, ['Content-Type' => 'application/x-www-form-urlencoded'], $uri->query);
	}
	
	$req->authorization_basic( $self->{email}, $self->{api_key} );
	my $response = $self->{ua}->request($req);

	if($response->is_success)
	{
		my $payload;
		eval{ $payload = decode_json($response->content); };

		return $response if($@);
		return $payload;
	}
	else
	{
		# Give back the HTTP::Response for debugging and "wtf" analysis.
		return $response;
	}

}


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::HashBlue

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-HashBlue>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-HashBlue>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-HashBlue>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-HashBlue/>

=back


=head1 ACKNOWLEDGEMENTS

Richard Spence for providing further information and documentation.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Squeeks.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WebService::HashBlue
