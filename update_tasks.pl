#!/usr/bin/perl 

use 5.16.0;

use strict;
use warnings;

use YAML qw/LoadFile/;
use Path::Tiny;
use Data::Printer;
use Net::Hiveminder;

my $hive_tasks = LoadFile( 'todo.yaml' );

my $local_tasks = parse_tasks();

my $hive = Net::Hiveminder->new( use_config => 1 );

for my $task ( values %$local_tasks ) {
    my $id = $task->{record_locator};
    my @updates =  grep { $task->{$_} ne $hive_tasks->{$id}{$_} } keys $task
        or next;

    say "updating $id";
    say "\tfields: ", join ', ', @updates;
    say "\twere: ", join ', ', map { $hive_tasks->{$id}{$_} } @updates;
    say "\tnow: ", join ', ', map { $task->{$_} } @updates;

    $hive->update_task( $id => 
        map { $_ => $task->{$_} } @updates
    );

}

sub parse_tasks {
    my $file = path( 'todo.md' );

    my @tasks = split qr/\n(?=\[.\])/, $file->slurp;

    my %tasks;

    for my $t ( @tasks ) {
        my %t;
        if( $t =~ /\[(.)\].*P(\d)\s+&([0-9A-Z]+)/ ) {
            @t{'record_locator','priority','complete'} = ( $3, $2, ( $1 eq ' ' ? 0 : 1 ));
        }
        next unless $t{record_locator};
        $tasks{ $t{record_locator} } = \%t;
    }

    return \%tasks;
}





