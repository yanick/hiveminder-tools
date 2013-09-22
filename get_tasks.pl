#!/usr/bin/perl 

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

DumpFile( 'todo.yaml', \%tasks );

my @sort_due_date = (
    map  { "" . now()->add( weeks => $_ ) } 0, 16, 8, 4, 2, 1
);

for ( values %tasks ) {
    $_->{sorting_date} = $_->{due} || $sort_due_date[ $_->{priority} ];
}

my @sorted_tasks = reverse sort {
    $b->{sorting_date} cmp $a->{sorting_date}
        or $a->{priority} <=> $b->{priority}
        or $a->{created} cmp $b->{created}
} values %tasks;

my @t;
for ( @sorted_tasks ) {
    my @d = split ' ', $_->{depends_on_ids};
    next if grep { $tasks{$_} } @d;
    push @t, $_;
}
@sorted_tasks = @t;

open STDOUT, '>', 'todo.md';

print_task($_) for @sorted_tasks;

sub print_task {
    my $t = shift;

    $_->{summary} =~ s/(?<=.{57}).{4,}/.../;
    printf "[ ] %-60s P%d %s%s\n", $_->{summary}, $_->{priority}, "&", $_->{record_locator};
    print '  tags: ', join( ' ', $_->{tags} =~ /"(.+?)"/g ), "\n" if $_->{tags};
    for my $field ( qw/ due / ) {
        next unless defined $_->{$field};
        print '  ', $field, ': ', $_->{$field}, "\n";
    }
    print "\n";
}

