@extends('layouts.app')

@section('shopping-cart')
    <div class="shopping-cart">
        <div class="shopping-cart-info">
            <h1>Your Shopping Cart</h1>
            @if(!$shoppingCart || $shoppingCart->isEmpty())
                <p>Your cart is empty.</p>
            @else
                <table class="shopping-cart-table">
                    <thead>
                        <tr>
                            <th>Game</th>
                            <th>Price</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($shoppingCart as $item)
                            <tr>
                                <td><a href="{{ url('/games/' . $item->game->id) }}">{{ $item->game->name }}</a></td>
                                <td>€{{ number_format($item->game->discount_price ?? $item->game->price, 2) }}</td>
                                <td>
                                    <form id="remove-from-cart-form-{{ $item->game->id }}" action="{{ route('cart.remove', $item->game->id) }}" method="POST">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn-remove">Remove</button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </div>
        <div class="shopping-cart-checkout">
            <h1>Order Summary</h1>   
            <p><strong>Total:</strong> €{{ number_format($totalPrice, 2) }}</p>
            <form method="GET" action="{{ route('checkout') }}">
                @csrf
                <button type="submit" class="btn-checkout">Checkout</button>
            </form>
        </div>
    </div>
@endsection
