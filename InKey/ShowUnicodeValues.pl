#  ShowUnicodeValues.pl
#
# View the Unicode values and names of characters in the upper Edit control.
# Technically, "this application does not accept Unicode input", so Keyman will not be able to
# type directly into the Edit control.  (You can paste the text in, instead.)
# InKey, on the other hand, enables much more to be typed directly in.

use strict;

#________________________________________________________________________________
# The computational part of the script, not related to the user interface.

use Unicode::CharName('uname');

# generateOutput($inputstring) returns a list of strings.
#   This function is given an input string, and returns a list of output strings.
#   The input is a string containing Unicode characters.
#   For each input character, one output string provides the character, character code, and Unicode name.
sub generateOutput {
	my @outputlines;
	foreach (split //, $_[0]) {
		if (ord($_) == 32) {
			push @outputlines, ("-" x 20) . " <space>";
		} else {
			push @outputlines, sprintf "$_\tU+%04X\t%s", ord($_),uname(ord($_));
		}
	}
	return @outputlines;
}

#________________________________________________________________________________
# The TK part of the script, to manage the user interface.

use Tk;
#my $font = '{Kalinga} 24'; 		# For Oriya
my $font = '{Arial Unicode MS} 24'; 		# Font setting (especially size may be significant)
# my $font = '{Doulos SIL}30';

# Create the main window
my $mw = MainWindow->new;
$mw->configure(-title => "Show Unicode Values");
my $output;

# Create an Entry control for input
my $entryline = $mw->Entry(
	-width => 60,
	-validate => 'key',
	-vcmd => sub { $output->Contents(join "\n", generateOutput($_[0])); 1 },
	-borderwidth => 2,
	-font => $font,
		);
$entryline->pack;
$entryline->focusForce;

# Create a scrolled text control for output
$output = $mw->Scrolled(qw/Text -relief flat -borderwidth 2 -setgrid true -wrap none -background gray -height 12 -scrollbars e -spacing3 2/);
$output->configure(-font => $font);
$output->pack(qw/-expand yes -fill both/);

# Run TK
MainLoop;
