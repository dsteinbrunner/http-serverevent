package HTTP::ServerEvent;
use strict;
use Carp qw( croak );

=head1 NAME

HTTP::ServerEvent - create strings for HTTP Server Sent Events

=cut

=head2 C<< ->as_string( %options ) >>

  return HTTP::ServerEvent->as_string(
    type => "ping",
    data => time(),
    retry => 5000, # retry in 5 seconds
    id => $counter++,
  );

=cut

    use Data::Dumper;
sub as_string {
    my ($self, %options) = @_;
    
    # Better be on the safe side
    croak "No type given"
        unless length $options{ type };
    croak "Newline or null detected in event type '$options{ type }'. Possible event injection."
        if $options{ type } =~ /[\x0D\x0A\x00]/;
    
    if( !$options{ data }) {
        $options{ data }= [];
    };
    $options{ data } = [ $options{ data }]
        unless 'ARRAY' eq ref $options{ data };
    
    my @result= "event:$options{ type }";
    if(my $id= delete $options{ id }) {
        push @result, "id: $id";
    };
    
    if( my $retry= delete $options{ retry }) {
        push @result, "retry: $retry";
    };
    
    push @result, map {"data: $_" }
                  map { split /(?:\x0D\x0A?|\x0A)/ }
                  @{ $options{ data } || [] };
    
    return ((join "\x0D", @result) . "\x0D")
};

1;

=head1 SEE ALSO

L<https://developer.mozilla.org/en-US/docs/Server-sent_events/Using_server-sent_events>

L<https://hacks.mozilla.org/2011/06/a-wall-powered-by-eventsource-and-server-sent-events/>

L<http://www.html5rocks.com/en/tutorials/eventsource/basics/?ModPagespeed=noscript>

=cut