@extends('layouts.app')

@section('content')
    <div class="wishlist">
        <div class="wishlist-info">
            <h1>Your Wishlist</h1>
            @if(!$wishlist || $wishlist->isEmpty())
                <p>Your wishlist is empty.</p>
            @else
                <table class="wishlist-table">
                    <thead>
                        <tr>
                            <th>Game</th>
                            <th>Price</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($wishlist as $item)
                            <tr>
                                <td><a href="{{ url('/games/' . $item->game->id) }}">{{ $item->game->name }}</a></td>
                                <td>€{{ number_format($item->game->discount_price ?? $item->game->price, 2) }}</td>
                                <td class="wishlist-game-actions">
                                    <form action="{{ route('cart.add', $item->id_game) }}" method="POST">
                                        @csrf
                                        <button type="submit" class="btn btn-outline-dark">Add to Cart</button>
                                    </form>

                                    <form id="remove-from-wishlist-form-{{ $item->id_game }}" action="{{ route('wishlist.remove', $item->id_game) }}" method="POST">
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
    </div>
@endsection
