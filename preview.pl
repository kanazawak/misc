#!/usr/bin/env perl

use File::stat;

my %is_binary_ext = (
  'pdf' => 1,
  'app' => 1
);

sub is_binary {
  /\.([^.\/]+)$/;
  return $is_binary_ext{$1} || ! (-d || -T);
}

sub is_directory {
  /\.([^.\/]+)$/;
  return !$is_binary_ext{$1} && -d;
}

sub header {
  /(^|\/)([^\/]+)$/;
  my $name = $2;

  my $stat_format =<<'__EOS__';
Permission: %Sp
Created:    %SB
__EOS__
  my $time_format = '%y/%m/%d %H:%M:%S';
  my $stat = `stat -f '$stat_format' -t '$time_format' '$_'`;

  return "$name\n$stat\n";
}

sub preview_binary_file {
  print header;
  system("ql2stdout '$_' | wezterm imgcat");
}

sub preview_directory {
  open my $out, '|-', 'less',
    '--RAW-CONTROL-CHARS';
  print $out header;

  open my $in, '-|', 'ls',
    '-1pFG',
    '--color=force',
    $_;
  print $out $_ while (<$in>);

  close $in;
  close $out;
}

sub preview_text_file {
  open my $out, '|-', 'less',
    '--chop-long-lines',
    '--RAW-CONTROL-CHARS';
  print $out header;

  open my $in, '-|', 'bat',
    '--plain',
    '--wrap', 'never',
    '--color', 'always',
    $_;
  print $out $_ while (<$in>);

  close $in;
  close $out;
}

while (<>) {
  system 'clear';
  chomp;
  if    (! -e)         { print STDERR "The path not exists.\n" }
  elsif (is_binary)    { preview_binary_file }
  elsif (is_directory) { preview_directory }
  else                 { preview_text_file }
}
