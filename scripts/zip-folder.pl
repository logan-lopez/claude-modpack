#!/usr/bin/perl
# zip-folder.pl OUT.zip FOLDER: zips FOLDER, as a top-level folder, into a new OUT.zip.
# For scripts/server-pack.sh, in place of `zip -qrX`, which Git Bash on Windows doesn't have.
# IO::Compress::Zip comes with Perl everywhere. Modes are set here, not read from the disk,
# because Windows has none to read: *.sh 755, other files 644, folders 755.
use strict;
use warnings;
use File::Find;
use IO::Compress::Zip qw($ZipError);

my ($out, $dir) = @ARGV;
die "usage: zip-folder.pl OUT.zip FOLDER\n" unless defined $dir && -d $dir;
die "zip-folder.pl: $out exists\n" if -e $out;

my @paths;
find({ no_chdir => 1, wanted => sub { push @paths, $File::Find::name } }, $dir);

my $zip;
for my $path (sort @paths) {
  my $dirent = -d $path;
  my $mode = $dirent ? 040755 : $path =~ /\.sh$/ ? 0100755 : 0100644;
  my %member = (
    Name    => $dirent ? "$path/" : $path,
    Time    => (stat $path)[9],
    OS_Code => 3,                                    # Unix, so unzip reads the modes
    ExtAttr => ($mode << 16) | ($dirent ? 0x10 : 0), # 0x10: the MS-DOS directory bit
    Method  => 8,                                    # deflate
  );
  if ($zip) {
    $zip->newStream(%member) or die "zip-folder.pl: $ZipError\n";
  } else {
    $zip = IO::Compress::Zip->new($out, %member) or die "zip-folder.pl: $ZipError\n";
  }
  next if $dirent;
  open my $in, '<:raw', $path or die "zip-folder.pl: $path: $!\n";
  my $buf;
  while (read $in, $buf, 1 << 20) {
    $zip->print($buf) or die "zip-folder.pl: $ZipError\n";
  }
  close $in;
}
$zip->close or die "zip-folder.pl: $ZipError\n";
