package Foo::Two;

sub mycallback_order { 0 }
sub mycallback { Test::More::is($::order++, 1, "First plugin") }

1;
