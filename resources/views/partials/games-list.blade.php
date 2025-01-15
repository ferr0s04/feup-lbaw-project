@foreach ($games as $game)
    @include('partials.game-display', ['game' => $game])
@endforeach