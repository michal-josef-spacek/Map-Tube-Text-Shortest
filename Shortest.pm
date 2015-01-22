package Map::Tube::Text::Shortest;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use List::Util qw(reduce);
use Readonly;
use Scalar::Util qw(blessed);

# Constants.
Readonly::Scalar our $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Map::Tube object.
	$self->{'tube'} = undef;

	# Process params.
	set_params($self, @params);

	# Check Map::Tube object.
	if (! defined $self->{'tube'}) {
		err "Parameter 'tube' is required.";
	}
	if (! blessed($self->{'tube'})
		|| ! $self->{'tube'}->does('Map::Tube')) {

		err "Parameter 'tube' must be 'Map::Tube' object.";
	}

	# Object.
	return $self;
}

# Print shortest table.
sub print {
	my ($self, $from, $to) = @_;
	my $route = $self->{'tube'}->get_shortest_route($from, $to);
	my $header = sprintf 'From %s to %s', $route->from->name,
		$route->to->name;
	my @output = (
		$EMPTY_STR,
		$header,
		'=' x length $header,
		$EMPTY_STR,
		sprintf '-- Route %d (cost %s) ----------', 1, '?',
	);
	my $line_id_length = length
		reduce { length($a) > length($b) ? $a : $b }
		map { $_->id || '?'} @{$self->{'tube'}->get_lines};
	foreach my $node (@{$route->nodes}) {
		my $num = 0;
		foreach my $line (@{$node->line}) {
			$num++;
			my $line_id = $line->id || '?';
			push @output, sprintf "[ %1s %-${line_id_length}s ] %s",
				# TODO +
				$num == 2 ? '*' : $EMPTY_STR,
				$line_id,
				$node->name;
		}
	}
	# TODO Links of lines.
	push @output, (
		$EMPTY_STR,
		'*: Transfer to other line',
		'+: Transfer to other station',
		$EMPTY_STR,
	);
	return wantarray ? @output : join "\n", @output;
}

1;

__END__
