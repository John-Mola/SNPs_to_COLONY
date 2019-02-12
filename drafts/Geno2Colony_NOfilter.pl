#!/usr/bin/perl

$geno = $ARGV[0];
$list = $ARGV[1];

#SNP Filters
#$max_mis = 0.50;
#$min_maf = 0.05;
#$max_chi = 3.84;

#SNP Drawing
#$num = 5000;
#$dist = 5000;

#Colony
$type = 0;
$adrop = 0.05;
$gerror = 0.05;

open(FILE, "<$geno") or die;

$x = 0;
while (<FILE>) {
	$line = $_; chomp($line);
	$line =~ s/N/0/g;
	$line =~ s/A/1/g;
	$line =~ s/C/2/g;
	$line =~ s/G/3/g;
	$line =~ s/T/4/g;
	$lines[$x] = $line;
	$x++;
}
close FILE;

@tested = (0)x($x-1);
$x = 0;
while ($x < $num) {
	$n = int rand(scalar(@lines));
	if ($tested[$n] == 0) {
		$tested[$n] = 1;
		@tabs = split(/\t/,$lines[$n]);

		@homo = (0)x6;
		@allele = (0)x6;
		$het = 0;
		$y = 2;
		while ($y <= $#tabs) {
			($a1,$a2) = split(//,$tabs[$y]);
			$allele[$a1]++;
			$allele[$a2]++;
			if ($a1 != $a2) {
				$het++;
			} else {
				$homo[$a1]++;
			}
			$y++;
		}

		$y = 1;
		$major = 5;
		$minor = 5;
		while ($y <= 4) {
			if ($allele[$y] > 0) {
				if ($allele[$y] > $allele[$major]) {
					$minor = $major;
					$major = $y;
				} else {
					$minor = $y;
				}
			}
			$y++;
		}

		$mis = $homo[0]/($homo[0]+$homo[$major]+$homo[$minor]+$het);
		$maf = $allele[$minor]/($allele[$major]+$allele[$minor]);

#		print "$tabs[0]\t$tabs[1]\t$major\t$minor\t$mis\t$maf\n";

#		$P = (1-$maf)**2;
#		$Q = $maf**2;
#		$H = 1-$P-$Q;

#		$eP = $P*($homo[$major]+$homo[$minor]+$het);

#		$eQ = $Q*($homo[$major]+$homo[$minor]+$het);
#		$eH = $H*($homo[$major]+$homo[$minor]+$het);

#		$fail = 0;
#		if ($maf > 0) {
#			$chi = (($eP-$homo[$major])**2)/$eP;
#			$chi = $chi + (($eQ-$homo[$minor])**2)/$eQ;
#			$chi = $chi + (($eH-$het)**2)/$eH;
#		} else {
#			$fail = 1;
#		}

#		if ($mis <= $max_mis && $maf >= $min_maf && $chi <= $max_chi && $fail == 0) {
#			$fail = 0;
#			if ($used{$tabs[0]} ne "") {
#				@commas = split(/\,/,$used{$tabs[0]});
#				$y = 0;
#				while ($y <= $#commas) {
#					if ($commas[$y] ne "") {
#						if ($tabs[1] > ($commas[$y]-$dist) && $tabs[1] < ($commas[$y]+$dist)) {
#							$fail = 1;
#						}
#					}
#					$y++;
#				}
#			}

#			if ($fail == 0) {
#				$used{$tabs[0]} = $used{$tabs[0]} . $tabs[1] . ",";
#				$good[$x] = $lines[$n];
#				$x++;
#			}
#		}
#	} else {
#		$sum = eval join '+', @tested;
#		if ($sum == scalar(@tested)) {
#			$x = $num;
#		}
	}
}

open(FILE, "<$list") or die;

while (<FILE>) {
        $line = $_; chomp($line);
	$inds[++$#iinds] = $line . "\t";
}
close FILE;

$x = 0;
while ($x <= $#good) {
	@tabs = split(/\t/,$good[$x]);
	$y = 2;
	$head1 = $head1 . $tabs[0] . "_" . $tabs[1] . "\t";
	$head2 = $head2 . "$type\t";
	$head3 = $head3 . "$adrop\t";
	$head4 = $head4 . "$gerror\t";

	while ($y <= $#tabs) {
		$inds[$y-2] = $inds[$y-2] . "\t" . $tabs[$y];
		$y++;
	}
	$x++;
}
chop($head1); chop($head2); chop($head3); chop($head4);
print "$head1\n$head2\n$head3\n$head4\n\n";

$x = 0;
while ($x <= $#inds) {
        @tabs = split(/\t/,$inds[$x]);
	$line = "$tabs[0]\t";
	$y = 1;
	while ($y <= $#tabs) {
		($a1,$a2) = split(//,$tabs[$y]);
		$line = $line . "$a1 $a2\t";
		$y++;
	}
	chop($line); print "$line\n";
        $x++;
}
