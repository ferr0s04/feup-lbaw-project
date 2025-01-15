@extends('layouts.app')

@section('title', $category->category_name)

@section('content')
    <div class="container">
        <h1>{{ $category->category_name }}</h1>
        <p>Games in this category:</p>

        @if($games->isEmpty())
            <p>No games available in this category.</p>
        @else
            <div class="games-list">
                @foreach ($games as $game)
                    @include('partials.game-display', ['game' => $game])
                @endforeach
            </div>
        @endif
    </div>
@endsection