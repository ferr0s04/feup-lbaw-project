@extends('layouts.app')

@section('content')
<div class="about-us container mt-5">
    <h1>About Us</h1>
    <p>
        Welcome to PixelMarket, your trusted online platform for buying and selling games. Our mission is to connect gamers and game sellers 
        from all over the world in a safe, efficient, and transparent marketplace.
    </p>
    
    <h2>Our Mission</h2>
    <p>
        At PixelMarket, we strive to empower gamers and developers by creating a space where quality games can reach passionate players.
        We believe in fostering a community where trust and excitement for gaming take center stage.
    </p>

    <h2>Why Choose Us?</h2>
    <ul>
        <li>Wide selection of games from top sellers and independent creators.</li>
        <li>Secure transactions with buyer and seller protection.</li>
        <li>Innovative tools for sellers to maximize their reach and earnings.</li>
    </ul>

    <h2>Contact Us</h2>
    <p>
        Have any questions or feedback? Feel free to <a href="{{ url('/contact') }}">contact us</a>. 
        We’d love to hear from you!
    </p>
</div>
@endsection
