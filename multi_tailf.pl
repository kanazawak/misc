#!/usr/bin/env perl

use strict;
use warnings;
use IO::Select;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

multi_tailf.pl - tailf files keeping position

=head1 SYNOPSIS

./multi_tailf.pl [-n positive_integer] file ...

=cut

sub clear {
	print "\e[2J\e[0;0H";
}

{
    package Block;

    sub new {
        my ($class, $file_name, $line_num) = @_;
        bless {
            file_name => $file_name,
            text => "",
            lines => [],
            line_num => $line_num,
        }, $class;
    }

    sub add {
        my ($self, $str) = @_;
        my @arr = split "\n", $str;
        my $lines = $self->{lines};
        push @$lines, $_ for @arr;
        shift @$lines while @$lines > $self->{line_num};
    }

    sub stringify {
        my ($self) = @_;
        "--- " . $self->{file_name} . " ---\n" . join("\n", @{$self->{lines}}) . "\n";
    }
}

my $line_num = 10;
GetOptions('n=i' => \$line_num) || pod2usage();
@ARGV || pod2usage();
pod2usage() if $line_num <= 0;

my @blocks;
my %index;
my $selector = IO::Select->new;
for my $file (@ARGV) {
	open(my $check, '<', $file) || die $!;
    close $check or die $!;
	open(my $fh, '-|', "tail -f -n $line_num $file") || die $!;
	$selector->add($fh);
    push @blocks, Block->new($file, $line_num);
	$index{$fh} = keys %index;
}

clear;
while (1) {
	my @ready = $selector->can_read(0.1);
	if (@ready) {
		for my $fh (@ready) {
            sysread($fh, my $buf, 1024);
            my $i = $index{$fh};
            $blocks[$i]->add($buf);
		}
        clear;
        print join("", map {$_->stringify} @blocks);
	}
}
