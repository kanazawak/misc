#!/usr/bin/env perl

local $| = 1;

while (<>) {
  print;
  if (/Building\.\.\./) {
    print "\x1b]51;[\"call\",\"Tapi_qfclear\",[]]\x07";
  } elsif (/^(.+.cs)\((\d+),(\d+)\): error (.+?)( \[.+\])?$/) {
    my $file = $1;
    my $lnum = $2;
    my $col  = $3;
    my $text = $4;
    print "\x1b]51;[\"call\",\"Tapi_qfadd\",[\"$file\",$lnum,$col,\"$text\"]]\x07";
  }
}
