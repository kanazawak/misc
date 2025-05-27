#!/usr/bin/env perl

use File::stat qw(lstat);
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

  my $st = lstat($_);
  my $mode = $st->mode;
  my $mode_str =
    (   S_ISREG($mode)  ? '-'
      : S_ISDIR($mode)  ? 'd'
      : S_ISLNK($mode)  ? 'l'
      : S_ISCHR($mode)  ? 'c'
      : S_ISBLK($mode)  ? 'b'
      : S_ISFIFO($mode) ? 'p'
      : S_ISSOCK($mode) ? 's'
      :                   '?' )
    . ($mode & S_IRUSR ? 'r' : '-')
    . ($mode & S_IWUSR ? 'w' : '-')
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
    '-1pFGH',
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

$_ = $ARGV[0];
chomp;
system 'clear';
if    (! -e)         { print STDERR "The path not exists.\n" }
elsif (is_binary)    { preview_binary_file }
elsif (is_directory) { preview_directory }
else                 { preview_text_file }
