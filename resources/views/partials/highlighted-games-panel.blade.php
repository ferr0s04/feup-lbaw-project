@extends('layouts.app')

@section('content')
<h1 class="textdiuted">Highlighted Games</h1>
<div class="row">
    @foreach($highlightedGames as $index => $game)
        @include('partials.game-display', ['game' => $game]) 
    @endforeach
</div>

@endsection