#!/usr/bin/env perl 

use 5.16.0;

use strict;
use warnings;

use YAML qw/LoadFile/;
use Path::Tiny;
use Data::Printer;
use Net::Hiveminder;

my $hive_tasks = LoadFile( '/home/yanick/.todo.yaml' );

my $in = join '', <>;

my $local_tasks = parse_tasks( $in );

my $hive = Net::Hiveminder->new( use_config => 1 );

for my $task ( values %$local_tasks ) {
    my $id = $task->{record_locator};
    my @updates =  grep { $task->{$_} ne $hive_tasks->{$id}{$_} } keys $task
        or next;

    #warn "updating $id";
    #warn "\tfields: ", join ', ', @updates;
    #warn "\twere: ", join ', ', map { $hive_tasks->{$id}{$_} } @updates;
    #warn "\tnow: ", join ', ', map { $task->{$_} } @updates;

    $hive->update_task( $id => 
        map { $_ => $task->{$_} } @updates
    );

}

print $in;

sub parse_tasks {
    my @tasks = split qr/\n\s*\*\s+(?=\[.\])/, shift;

    my %tasks;

    for my $t ( @tasks ) {
        my %t;
        if( $t =~ /^\s*\*\s+\[(.)\].*P(\d)\s+&([0-9A-Z]+)/m ) {
            @t{'record_locator','priority','complete'} = ( $3, $2, ( $1 eq 'X' ? 1 : 0 ));
        }
        next unless $t{record_locator};
        $tasks{ $t{record_locator} } = \%t;
    }

    return \%tasks;
}





