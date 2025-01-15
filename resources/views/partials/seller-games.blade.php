<div class="container mt-5">
    <div class="text-center mb-4">
        <h1 class="display-7">My Games</h1>
    </div>

    @if ($sellerGames->isEmpty())
        <p class="text-center">You have no games listed for sale.</p>
    @else
        <div class="container"
            style="max-height: 20vh; overflow-y: auto; scrollbar-width: none; -ms-overflow-style: none; border: 1px solid #ccc; padding-top: 10px; padding-bottom: 10px;">
            @foreach ($sellerGames as $game)
                <div class="mb-4">
                    @include('partials.game-display', ['game' => $game])
                </div>
            @endforeach
        </div>
    @endif
</div>