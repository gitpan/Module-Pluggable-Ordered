package Foo::One;

sub mycallback_order { 20 }
sub mycallback { Test::More::is($::order++, 2, "Second plugin") }

1;
