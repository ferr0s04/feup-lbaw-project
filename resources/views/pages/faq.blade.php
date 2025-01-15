@extends('layouts.app')

@section('content')
<div class="features container mt-5">
    <h1>Main Features</h1>
    <p>
        PixelMarket provides everything you need to seamlessly buy and sell games online. 
        Here’s a look at some of our core features:
    </p>

    <h2>For Buyers</h2>
    <ul>
        <li>
            <strong>Extensive Game Library:</strong> Browse a wide selection of games from various genres, developers, and platforms.
        </li>
        <li>
            <strong>Secure Checkout:</strong> Enjoy safe and encrypted payment methods for a worry-free transaction.
        </li>
        <li>
            <strong>Personalized Recommendations:</strong> Discover new games based on your purchase history and preferences.
        </li>
    </ul>

    <h2>For Sellers</h2>
    <ul>
        <li>
            <strong>Easy Game Listings:</strong> Upload your game with an intuitive interface and reach thousands of buyers.
        </li>
        <li>
            <strong>Sales Insights:</strong> Track your sales performance and customer reviews with detailed analytics.
        </li>
        <li>
            <strong>Seller Protection:</strong> Benefit from our fraud detection and secure payout systems.
        </li>
    </ul>

    <h2>Community Features</h2>
    <ul>
        <li>Rate and review games to share your opinion with other gamers.</li>
        <li>Follow your favorite sellers and get notified of their new releases.</li>
        <li>Participate in special events and game promotions.</li>
    </ul>

    <p>
        Ready to experience all these features? <a href="{{ url('/register') }}">Join PixelMarket</a> today!
    </p>
</div>
@endsection
