# InsertUnicodeCmts.pl
#
# Use this perl script to generate comments that document:
#  - the characters in a "double-quoted" InKey rota string, or
#  - referenced by hex value, on a line containing a comment that begins with   ;|
#  - every character (excluding whitespace) on a line preceeding ;]
#
# NO GUARANTEES!!   ALWAYS KEEP A BACKUP OF YOUR ORIGINAL!!
# Usage:
#   InsertUnicodeCmts.pl source.ahk dest.ahk

$markLoop = " \x{21d4}";
$markNonLoop = " \x{219A}";

use Unicode::CharName('uname');
use utf8;
   use open IN  => ":utf8", OUT => ":utf8";


unless ($#ARGV == 1) { die "usage:\n\trota2cmt.pl source.ahk dest.ahk\n"; }

open IN, $ARGV[0] or die "Can't read from " . $ARGV[0] . "\n";
open OUT, ">" . $ARGV[1] or die "Can't write to " . $ARGV[1] . "\n";

read IN, $buf, -s $ARGV[0];

# trimRotaSection();  # trim the rest of the script off

@a = split /\n/, $buf;
foreach $ln(@a) {
	next if ($ln =~ /^\;\|/);	# skip any lines beginning with ;| as these comments were auto-generated.
	if ($ln =~ /\;\|/) {
		$ln = $` . $&;
		@h = ($ln =~ /0x[0-9A-Fa-f]+/g);
		$hh = "\t";
		foreach (@h) {
			s/^0x//;
			$v = hex($_);
			$c = chr($v);
			$u = lc uname($v);
			$u =~ s/ /_/g;
			if ($u =~ /combining/) { $c = "\x{25cc}$c" }
			$u = "<???>" unless $u;
			$hh .= "$u ($c)  ";
		}
		$ln .= "$hh";
	} elsif ($ln =~ /(\s)\S+\s*(?=\;\])/) {
		$ln = $` . $&;
		$hh = ";]" . (($1 eq "\t") ? $markNonLoop : $markLoop) . "\t";
		@tok = ($ln =~ /\S+/g);
		undef @chars;
		undef @nums;
		undef @names;
		foreach $t (@tok) {

			$word = '';
			$wNum = '';
			$wName = '';
			@c = split / */, $t;
			foreach $c (@c) {
				$v = ord($c);
				$u = lc uname($v);
				$u =~ s/ /_/g;
				if ($u =~ /combining/) { $c = "\x{25cc}$c" }
				$u = "<???>" unless $u;
				$word .= $c;
				$h = sprintf("%04X", $v);
				$wNum .= " $h";
				$wName .= " $u";
			}
			push @chars, $word;
			push @nums, $wNum;
			push @names, $wName;
		}
		$ln .= "$hh" . join(" | ", @nums) . "\t" . join(" | ", @names);
	}
	print OUT "$ln\n";
	if ($ln =~ /RegisterRota.*?\"(.*)\"/i) {
		@set = split /\t/, $1;
		foreach (@set) {
			undef @chars;
			undef @nums;
			undef @names;
			@tok = split / /, $_;
			foreach $t (@tok) {
				$word = '';
				$wNum = '';
				$wName = '';
				@c = split / */, $t;
				foreach $c (@c) {
					$v = ord($c);
					$u = lc uname($v);
					$u =~ s/ /_/g;
					if ($u =~ /combining/) { $c = "\x{25cc}$c" }
					$u = "<???>" unless $u;
					$word .= $c;
					$h = sprintf("%04X", $v);
					$wNum .= " $h";
					$wName .= " $u";
				}
				push @chars, $word;
				push @nums, $wNum;
				push @names, $wName;
			}
			print OUT ";|\t" . join(" ", @chars) . "\t\t" . join(" | ", @nums) . "\t\t" . join(" | ", @names) . "\n";
		}
	}
}


# sub trimRotaSection {
	# unless ($buf =~ /\n\n([^\n])*?\s*RegisterRota/is) { die "Could not find a RegisterRota call.\n" }
	# $buf = $& . $'; # trim the earlier part of the file
	# if   ($buf =~ /(.*)(RegisterRota(.*?))$/si) {
		# $b2 = $2;
		# $buf = $1;
		# unless ($b2 =~ s/\n\s*\n.*$//s) { die "no b2" }
		# $buf .= $b2;
	# } else { die "cannot trim" }
# }
