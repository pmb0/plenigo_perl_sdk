package plenigo::CheckoutHelper;

=head1 NAME

 plenigo::CheckoutHelper - A utility class offering support for checkout functionality. 

=head1 SYNOPSIS

 use plenigo::CheckoutHelper;

 my $product = plenigo::Product->createPlenigoProduct('PRODUCT_ID');
 my $checkout_helper = plenigo::CheckoutHelper->new(configuration => $configuration);
 my $checkout_code = $checkout_helper->createCheckoutCode($product);

=head1 DESCRIPTION

 plenigo::CheckoutHelper provides functionality to prepare a plenigo checkout.

=cut

use Moo;
use Carp qw(confess);
use Crypt::JWT qw(encode_jwt);
use Data::UUID;

our $VERSION = '2.0006';

has configuration => (
    is       => 'ro',
    required => 1
);

=head1 METHODS

=cut

=head2 createCheckoutCode($product)

 Create checkout code necessary for plenigo checkout.

=cut

sub createCheckoutCode {
    my ($self, $product) = @_;

    my $ug = Data::UUID->new;
    my $uuid = $ug->create();
    my %checkout_data = $product->createCheckoutData($self->configuration);
    $checkout_data{'jti'} = $ug->to_string($uuid);
    $checkout_data{'aud'} = 'plenigo';
    return encode_jwt(payload => {%checkout_data}, alg => 'HS256', key => $self->configuration->secret);
}

1;
