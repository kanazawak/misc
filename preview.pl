#!/usr/bin/env perl

use strict;
use warnings;

use File::stat;
use Fcntl qw(:mode);
use POSIX qw(strftime);

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

  my $st = stat($_);
  my $mode = $st->mode;
  my $mode_str =
    ( $mode & S_IFDIR ? 'd'
    : $mode & S_IFLNK ? 'l'
    :                   '-' )
    . ($mode & S_IRUSR ? 'r' : '-')
    . ($mode & S_IWUSR ? 'W' : '-')
    . ($mode & S_IXUSR ? 'x' : '-')
    . ($mode & S_IRGRP ? 'r' : '-')
    . ($mode & S_IWGRP ? 'w' : '-')
    . ($mode & S_IXGRP ? 'x' : '-')
    . ($mode & S_IROTH ? 'r' : '-')
    . ($mode & S_IWOTH ? 'w' : '-')
    . ($mode & S_IXOTH ? 'x' : '-');
  my $time_str = strftime "%Y-%m-%d %H:%M:%S", localtime($st->ctime);
  return <<"__EOS__";
$name
Mode:    $mode_str
Created: $time_str

__EOS__
}

sub preview_binary_file {
  print header;
  open my $out, '|-', 'wezterm', 'imgcat';
  open my $in, '-|', 'ql2stdout', $_;
  print $out $_ while (<$in>);
  close $in;
  close $out;
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
