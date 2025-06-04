#!/usr/bin/env perl

local $| = 1;

sub call {
  my ($func, $args) = @_;
  print "\x1b]51;[\"call\",\"Tapi_$func\",[$args]]\x07";
}

call 'qfopen';

while (<>) {
  print;
  if (/Building\.\.\./) {
    print "\x1b]51;[\"call\",\"Tapi_qfclear\",[]]\x07";
    call 'qfclear';
  } elsif (/^(.+.cs)\((\d+),(\d+)\): error (.+?)( \[.+\])?$/) {
    my $file = $1;
    my $lnum = $2;
    my $col  = $3;
    my $text = $4;
    print "\x1b]51;[\"call\",\"Tapi_qfadd\",[]\x07";
    call 'qfadd', "\"$file\",$lnum,$col,\"$text\"";
  }
}
