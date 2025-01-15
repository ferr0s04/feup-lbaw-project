@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Seller Profile: {{ $seller->name }}</h1>
    <p><strong>Email:</strong> {{ $seller->email }}</p>

    <h2>Seller's Games</h2>
    @if($sellerGames->isEmpty())
        <p class="text-muted">No games listed by this seller yet.</p>
    @else
        <div class="row">
            @foreach ($sellerGames as $game)
                <div class="col-md-4 mb-4">
                    <div class="card h-100 shadow-sm">
                        <!-- Delete Game Button (Red Trash Can Icon) -->
                        <form action="{{ route('admin.deleteGame', $game->id) }}" method="POST" 
                            class="position-absolute top-0 end-0 m-2">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger">
                                <i class="fa fa-trash"></i>
                            </button>
                        </form>
                        <!-- Game Image -->
                        <a href="{{ url('/games/' . $game->id) }}" class="text-decoration-none">
                            <div class="card-img-top" style="height: 200px; overflow: hidden;">
                                @if($game->images && count($game->images) > 0)
                                    <img src="{{ asset($game->images->first()->image_path) }}" 
                                         alt="{{ $game->name }}" 
                                         class="img-fluid w-100" 
                                         style="object-fit: cover; height: 100%;">
                                @else
                                    <img src="/img/noimage.jpg" 
                                         alt="Default Image" 
                                         class="img-fluid w-100" 
                                         style="object-fit: cover; height: 100%;">
                                @endif
                            </div>
                        </a>
                        <!-- Game Details -->
                        <div class="card-body">
                            <h5 class="card-title text-truncate">
                                <a href="{{ url('/games/' . $game->id) }}" class="text-dark">{{ $game->name }}</a>
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
    @include('partials.game-add', ['game' => $game])
</div>
@endsection
