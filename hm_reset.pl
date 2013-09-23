#!/usr/bin/env perl 

use 5.16.0;

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Net::Hiveminder;
use DateTime::Functions qw/ now /;
use Data::Printer;
use YAML qw/ DumpFile /;

my $hive = Net::Hiveminder->new( use_config => 1 );

my %tasks = map { $_->{record_locator} => $_ } $hive->todo_tasks;

DumpFile( '/home/yanick/.todo.yaml', \%tasks );
