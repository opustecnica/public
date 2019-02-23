#!/usr/bin/perl -w
# USAGE: ubnt_config2commands.pl <FILE>

use strict;
my $file = $ARGV[0] || die "You must supply a file to read.";

if (!open(FP, $file)) {
  print STDERR "ERROR: Unable to open $file: $!\n";
  exit(1);
}

my $data = join('', <FP>);
close(FP);

$data =~ s/\{\s*\}/{}/g;
$data =~ s/\/\*.*?\*\/\n*//g;

hash2sets(config2hash($data));

exit(0);

sub hash2sets {
  my $config = shift;
  my $start = shift || 'set';

  if (ref($config) ne 'HASH') {
    print STDERR "ERROR: '$config' is not a HASH at '$start'\n";
    exit(1);
  }

  foreach my $key (sort(keys(%{$config}))) {
    if (ref($config->{$key}) eq 'HASH') {
      if (keys($config->{$key}) == 0) {
        print "$start $key\n";
      } else {
        hash2sets($config->{$key}, "$start $key");
      }
    } elsif (ref($config->{$key}) eq 'ARRAY') {
      foreach my $val (sort(@{$config->{$key}})) {
        print "$start $key $val\n";
      }
    } else {
      print "$start $key " . $config->{$key} . "\n";
    }
  }
}

sub config2hash {
  my $config = shift;
  my $pad = shift || '';

  my (%hash);
  while ($config =~ m/^$pad(\S+)\s+(".+?"|\S+ \{\}|\S+\s+\{.*?\n$pad\}|{.*?\n$pad\}|\S+)/gsm) {
    my $tag = $1;
    my $info = $2;

    if ($info =~ m/^(\S+)\s+\{\n(\s*)(.*?)\n$pad\}/sm) {
      my $name = $1;
      $hash{$tag}{$name} = config2hash("$2$3", $2);
      next;
    } elsif ($info =~ m/^(\S+)\s+\{\}/sm) {
      $hash{$tag}{$1} = {};
      next;
    }

    if (ref($info) ne 'HASH' && $info =~ m/\{\n(\s*)(.*?)\n$pad\}/sm) {
      $info = config2hash("$1$2", $1);
    } elsif ($info eq '{}') {
      $info = {};
    }

    if (!exists($hash{$tag})) {
      $hash{$tag} = $info;
    } else {
      if (ref($hash{$tag}) ne 'ARRAY') {
        $hash{$tag} = [$hash{$tag}];
      }
      push(@{$hash{$tag}}, $info);
    }
  }

  return(\%hash);
}
