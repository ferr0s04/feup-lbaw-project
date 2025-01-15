@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Search Results for "{{ $query }}"</h1>

    @if($games->isEmpty())
        <p>No games found matching your search criteria.</p>
    @else
        <div class="game-list">
            @foreach($games as $game)
                @include('partials.game-display', ['game' => $game])
            @endforeach
        </div>
    @endif
</div>
@endsection
