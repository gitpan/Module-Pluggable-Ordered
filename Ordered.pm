package Module::Pluggable::Ordered;
use 5.006;
use strict;
use warnings;
require Module::Pluggable;
use UNIVERSAL::require;
our $VERSION = '1.1';

sub import {
    my ($self, %args) = @_;
    my $subname = $args{sub_name} || "plugins";

	my %only;
	my %except;

    %only   = map { $_ => 1 } @{$args{'only'}}    if defined $args{'only'};
    %except = map { $_ => 1 } @{$args{'$except'}} if defined $args{'except'};

    my $caller = caller;
	
    no strict; 

    *{"${caller}::call_plugins"} = sub {
        my ($thing, $name, @args)  = @_;
        my @plugins = ();
        for ($thing->$subname()) {
            next if (keys %only   && !$only{$_}   );
            next if (keys %except &&  $except{$_} );
            push @plugins, $_;
        }
            
        $_->require for @plugins;

        my $order_name = "${name}_order";
        for my $class (sort { $a->$order_name <=> $b->$order_name }
                       grep { $_->can($order_name) }
                       @plugins) {
            $class->$name(@args);
        }
    };
    goto &Module::Pluggable::import;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Module::Pluggable::Ordered - Call module plugins in a specified order

=head1 SYNOPSIS

    package Foo;
    use Module::Pluggable::Ordered;

    Foo->call_plugins("some_event", @stuff);

Meanwhile, in a nearby module...

    package Foo::Plugin::One;
    sub some_event_order { 99 } # I get called last of all
    sub some_event { my ($self, @stuff) = @_; warn "Hello!" }

And in another:

    package Foo::Plugin::Two;
    sub some_event_order { 13 } # I get called relatively early
    sub some_event { ... }

=head1 DESCRIPTION

This module behaves exactly the same as C<Module::Pluggable>, supporting
all of its options, but also mixes in the C<call_plugins> method to your
class. C<call_plugins> acts a little like C<Class::Trigger>; it takes the
name of a method, and some parameters. Let's say we call it like so:

    __PACKAGE__->call_plugins("my_method", @something);

C<call_plugins> looks at the plugin modules found using C<Module::Pluggable> 
for ones which provide C<my_method_order>. It sorts the modules
numerically based on the result of this method, and then calls
C<$_-E<gt>my_method(@something)> on them in order. This produces an
effect a little like the System V init process, where files can specify
where in the init sequence they want to be called.

=head1 OPTIONS

It also provides the C<only> and C<except> options.

     # will only return the Foo::Plugin::Quux plugin
     use Module::Pluggable::Ordered only => [ "Foo::Plugin::Quux" ];

     # will not return the Foo::Plugin::Quux plugin
     use Module::Pluggable::Ordered except => [ "Foo::Plugin::Quux" ];


=head1 SEE ALSO

L<Module::Pluggable>, L<Class::Trigger>

=head1 AUTHOR

Simon Cozens, E<lt>simon@cpan.orgE<gt>; please report bugs via the
CPAN Request Tracker.

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Simon Cozens

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
