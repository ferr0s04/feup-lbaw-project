@extends('layouts.app')

@section('checkout')
<div class="checkout-page">
        <!-- Payment Information Section -->
        <div class="">
            <h2>Payment Information</h2>
            <form id="payment-form" method="POST" action="{{ route('processPayment') }}">
                @csrf
                <div class="payment-info">
                <!-- Cardholder Name -->
                <label for="card-name">Cardholder Name</label>
                <input type="text" id="card-name" name="card_name" required placeholder="Cardholder Name">

                <label for="email">Email</label>
                <input type="text" name="email" id="email" required placeholder="Email">

                <label for="card-element">Card Details</label>
                <div id="card-element" class="stripe-card-element">
                    <!-- Stripe Element will be inserted here -->
                </div>
                <div id="card-errors" role="alert"></div>
                </div>

                        <!-- Order Summary Section -->
                <div class="order-summary">
                    <h2>Order Summary</h2>
                    <div class="order-items">
                        @if($shoppingCart && $shoppingCart->isNotEmpty())
                            <ul>
                                @foreach($shoppingCart as $item)
                                    <li>
                                        <span class="item-name">1x {{ $item->game->name }}</span>
                                        <span class="item-price">€{{ number_format($item->game->discount_price ?? $item->game->price, 2) }}</span>
                                    </li>
                                @endforeach
                            </ul>
                        @else
                            <p>Your shopping cart is empty.</p>
                        @endif
                    </div>

                    @if($shoppingCart && $shoppingCart->isNotEmpty())
                        <div class="order-total">
                            <span>Total:</span>
                            <span>
                                €{{ number_format($shoppingCart->sum(function($item) {
                                    return $item->game->discount_price ?? $item->game->price;
                                }), 2) }}
                            </span>
                        </div>

                        <button type="submit" class="place-order-btn">Place Order</button>
                    @endif
                </div>
            </form>
        </div>
</div>

<script src="https://js.stripe.com/v3/"></script>
<script>
    var stripe = Stripe("{{ env('STRIPE_KEY') }}");
    var elements = stripe.elements();
    var card = elements.create('card');
    card.mount('#card-element');

    // Handle form submission
    var form = document.querySelector('form[action="{{ route('processPayment') }}"]');
    form.addEventListener('submit', function(event) {
        event.preventDefault();

        var cardholderName = document.getElementById('card-name').value;
        var email = document.getElementById('email').value;

        stripe.createToken(card, {
            name: cardholderName,
        }).then(function(result) {
            if (result.error) {
                var errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
            } else {
                var token = result.token.id;

                var hiddenTokenField = document.createElement('input');
                hiddenTokenField.setAttribute('type', 'hidden');
                hiddenTokenField.setAttribute('name', 'stripeToken');
                hiddenTokenField.setAttribute('value', token);
                form.appendChild(hiddenTokenField);

                var hiddenNameField = document.createElement('input');
                hiddenNameField.setAttribute('type', 'hidden');
                hiddenNameField.setAttribute('name', 'card_name');
                hiddenNameField.setAttribute('value', cardholderName);
                form.appendChild(hiddenNameField);

                var hiddenEmailField = document.createElement('input');
                hiddenEmailField.setAttribute('type', 'hidden');
                hiddenEmailField.setAttribute('name', 'email');
                hiddenEmailField.setAttribute('value', email);
                form.appendChild(hiddenEmailField);

                form.submit();
            }
        });
    });
</script>

@endsection
