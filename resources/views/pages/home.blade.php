@extends('layouts.app')

@section('title', 'Homepage')

@section('content')

@include('partials.highlighted-sales-home')

@if ($games && count($games) > 0)
    <div class="container mt-3">
        <h1 class="textdiuted">Games</h1>
        <div id="game-container" style="overflow-y: auto; scrollbar-width: none; -ms-overflow-style: none; padding-top: 10px; padding-bottom: 10px;">
                @include('partials.games-list')
        </div>
    </div>
@endif

<div id="loading" style="display: none;">
    <p class="text-center">Loading...</p>
</div>

@endsection
