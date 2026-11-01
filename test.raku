#!/usr/bin/env raku

use v6.d;

$*OUT.out-buffer = False;

%*ENV<AUTHOR_TESTING> = 1;

chdir $*PROGRAM.parent;

my @stages = (
  { :name<prove6>, :cmd['prove6', '-Ilib', 't'] },
  { :name<behave>, :cmd['behave', 'specs'] },
);

my $only = @*ARGS[0];

my @run-stages = $only ?? @stages.grep({ .<name> eq $only }).list !! @stages;

if $only && !@run-stages {
  note "Unknown stage '$only'. Valid stages: {@stages.map(*.<name>).join(', ')}";
  exit 2;
}

for @run-stages -> $stage {
  say "==> {$stage<cmd>.join(' ')}";

  my $proc = run |$stage<cmd>;
  exit $proc.exitcode unless $proc.exitcode == 0;

  say '';
}
