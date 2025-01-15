@extends('layouts.app')

@section('title', 'Add Game')

@section('content')
<div class="container mt-5">
    <div class="text-center mb-4">
        <h1 class="display-5">Add New Game</h1>
    </div>

    <form id="gameForm" action="{{ route('games.create') }}" method="POST" enctype="multipart/form-data">
        @csrf
        @if(Auth::user()->role == 3)
            @php
                $sellers = App\Models\User::where('role', 2)->get(); // Assuming role 2 is for sellers
            @endphp
        @endif
        @include('partials.game-add', ['sellers' => $sellers ?? []])
    </form>
</div>
@endsection
