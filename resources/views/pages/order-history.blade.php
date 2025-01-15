@extends('layouts.app')

@section('content')
<div class="order-history-container">
    <h1>Your Order History</h1>

    @if ($orders->isEmpty())
        <p>No orders found.</p>
    @else
        @foreach ($orders as $order)
            <div class="order">
                <h2>Order #{{ $order->id }} - {{ $order->order_date->format('d M Y') }}</h2>
                <p>Total Price: €{{ number_format($order->total_price, 2) }}</p>

                <h3>Purchased Games:</h3>
                <ul>
                    @foreach ($order->gameOrderDetails as $gameOrderDetail)
                        <li>
                            <div>
                            <strong>{{ $gameOrderDetail->game->name }}</strong> - 
                            €{{ number_format($gameOrderDetail->purchase_price, 2) }}<br>
                            </div>

                            <button class="view-game-key-btn" data-game-id="{{ $gameOrderDetail->game->id }}">View Game Key</button>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endforeach
    @endif
</div>

<div id="gameKeyPopup" class="game-key-popup">
    <div class="game-key-popup-content">
        <span id="closePopup" class="close-popup-btn">&times;</span>
        <h2>Your Game Key</h2>
        <p id="gameKey"></p>
        <button id="copyGameKeyBtn" class="copy-to-clipboard-btn">
            <i class="fa fa-clipboard"></i> Copy to Clipboard
        </button>
    </div>
</div>

<script>
    function generateGameKey() {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let gameKey = '';
        for (let i = 0; i < 16; i++) {
            gameKey += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return gameKey;
    }

    document.querySelectorAll('.view-game-key-btn').forEach(button => {
        button.addEventListener('click', function() {
            const gameId = this.dataset.gameId;
            const generatedKey = generateGameKey();

            document.getElementById('gameKey').textContent = generatedKey;

            document.getElementById('gameKeyPopup').style.display = 'block';
        });
    });

    document.getElementById('closePopup').addEventListener('click', function() {
        document.getElementById('gameKeyPopup').style.display = 'none';
    });

    document.getElementById('copyGameKeyBtn').addEventListener('click', function() {
        const gameKey = document.getElementById('gameKey').textContent;

        navigator.clipboard.writeText(gameKey).then(() => {
            alert('Game key copied to clipboard!');
        });
    });
</script>

@endsection
