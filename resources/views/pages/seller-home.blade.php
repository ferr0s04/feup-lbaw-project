@extends('layouts.app')

@section('content')
@if(Auth::user()->role == 3 || Auth::user()->role == 2)
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1>Seller Profile: {{ $seller->name }}</h1>
                <p><strong>Email:</strong> {{ $seller->email }}</p>
            </div>
            <a href="{{ route('games.add') }}" class="btn btn-primary">
                Add New Game
            </a>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <!-- Header Text -->
            <h2 class="mb-0">{{ Auth::user()->role == 3 ? 'All Games' : 'Seller\'s Games' }}</h2>
            <!-- Search Bar -->
            <form class="d-flex" action="{{ route('seller.searchGames') }}" method="GET"
                style="border: 2px solid #5e5e5e; border-radius: 5px; width: fit-content; overflow: hidden;">
                <!-- Search Input -->
                <input type="text" class="form-control border-0" name="query" placeholder="Search your games"
                    value="{{ request('query') }}" style="width: 450px; height: 40px; padding: 0 10px;">
                <!-- Search Button -->
                <button class="btn d-flex justify-content-center align-items-center" type="submit"
                    style="background-color: #5e5e5e; width: 60px; height: 40px;">
                    <i class="fa-solid fa-magnifying-glass text-white"></i>
                </button>
            </form>
        </div>

        @if($sellerGames->isEmpty())
            <p class="text-muted">No games listed {{ Auth::user()->role == 3 ? 'yet.' : 'by this seller yet.' }}</p>
        @else
            <div class="row" id="games-container">
                @foreach ($sellerGames as $game)
                    <div class="col-md-4 mb-4">
                        <div class="card h-100 shadow-sm rounded">
                            <!-- Game Image -->
                            <a href="{{ route('seller', $game->id) }}" class="text-decoration-none">
                                <div class="card-img-top rounded-top" style="height: 200px; overflow: hidden;">
                                    @if($game->images && count($game->images) > 0)
                                        <img src="{{ asset($game->images->first()->image_path) }}" alt="{{ $game->name }}"
                                            class="img-fluid w-100 rounded-top" style="object-fit: cover; height: 100%;">
                                    @else
                                        <img src="{{ asset('img/noimage.jpg') }}" alt="Default Image"
                                            class="img-fluid w-100 rounded-top" style="object-fit: cover; height: 100%;">
                                    @endif
                                </div>
                            </a>
                            <!-- Game Details -->
                            <div class="card-body rounded-bottom">
                                <h5 class="card-title text-truncate">
                                    <a href="{{ route('seller', $game->id) }}" class="text-dark">{{ $game->name }}</a>
                                </h5>
                                <p class="text-muted">
                                    Categories:
                                    {{ $game->categories->pluck('category_name')->join(', ') ?? 'None' }}
                                </p>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif
    </div>

    <script>

    </script>
@else
    <div class="container">
        <h1>Unauthorized Access</h1>
        <p>You are not authorized to view this page.</p>
    </div>
@endif
@endsection