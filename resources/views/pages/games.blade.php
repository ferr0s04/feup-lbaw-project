@extends('layouts.app')

@section('title', 'Explore Games')

@section('content')
    <div class="container mt-4">
        <h1 class="text-center mb-4">EXPLORE ALL GAMES</h1>
        <p class="text-center text-muted">Filter by price, rating, or release date to find your perfect game!</p>

        <!-- Filtros -->
        <div class="d-flex justify-content-center mb-4">
            <form method="GET" action="{{ route('games.index') }}" class="d-flex gap-2">
                <div>
                    <label for="sort_by" class="form-label fw-bold">Order By</label>
                    <select name="sort_by" id="sort_by" class="form-select">
                        <option value="final_price" {{ request('sort_by') == 'final_price' ? 'selected' : '' }}>Price</option>
                        <option value="rating" {{ request('sort_by') == 'rating' ? 'selected' : '' }}>Rating</option>
                        <option value="release_date" {{ request('sort_by') == 'release_date' ? 'selected' : '' }}>Release Date</option>
                    </select>
                </div>
                <div>
                    <label for="direction" class="form-label fw-bold">Direction</label>
                    <select name="direction" id="direction" class="form-select">
                        <option value="asc" {{ request('direction') == 'asc' ? 'selected' : '' }}>Ascending</option>
                        <option value="desc" {{ request('direction') == 'desc' ? 'selected' : '' }}>Descending</option>
                    </select>
                </div>
                <div class="align-self-end">
                    <button type="submit" class="btn btn-custom me-2">APPLY FILTERS</button>
                </div>
            </form>
        </div>

        <!-- Grid de Jogos -->
        <div class="row g-4">
            @foreach ($games as $game)
                <div class="col-md-3">
                    <a href="{{ route('games.showinfo', $game->id) }}" class="text-decoration-none text-dark">
                        <div class="card h-100 shadow-sm">
                            <img src="{{ asset($game->images->first()->image_path ?? 'img/default.jpg') }}"
                                class="card-img-top" alt="{{ $game->name }}"
                                style="object-fit: cover; height: 250px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title text-center fw-bold">{{ Str::upper($game->name) }}</h5>
                                
                                @if($game->is_on_sale && $game->discount_price)
                                    <p class="text-center mb-1">
                                        <strong class="text-danger">€{{ number_format($game->discount_price, 2) }}</strong>
                                        <small class="text-muted text-decoration-line-through">€{{ number_format($game->price, 2) }}</small>
                                    </p>
                                    <p class="text-center text-success">On Sale!</p>
                                @else
                                    <p class="text-center mb-1"><strong>€{{ number_format($game->price, 2) }}</strong></p>
                                @endif

                                <p class="text-center mb-1">Rating: {{ number_format($game->rating, 1) ?? 'N/A' }}</p>
                                <p class="text-center text-muted small">Release: {{ $game->release_date ?? 'N/A' }}</p>
                            </div>
                        </div>
                    </a>
                </div>
            @endforeach
        </div>

        <!-- Pagination -->
        <div class="d-flex justify-content-center mt-4">
            @if ($games->lastPage() > 1)
                <ul class="pagination">
                    <!-- Previous Page Link -->
                    <li class="page-item {{ ($games->currentPage() == 1) ? 'disabled' : '' }}">
                        <a class="page-link" href="{{ $games->previousPageUrl() }}">Previous</a>
                    </li>

                    <!-- Page Numbers -->
                    @php
                        $currentPage = $games->currentPage();
                        $lastPage = $games->lastPage();
                        $rangeStart = max(1, $currentPage - 2);
                        $rangeEnd = min($lastPage, $currentPage + 2);
                    @endphp

                    @for ($i = $rangeStart; $i <= $rangeEnd; $i++)
                        <li class="page-item {{ ($games->currentPage() == $i) ? 'active' : '' }}">
                            <a class="page-link" href="{{ $games->url($i) }}">{{ $i }}</a>
                        </li>
                    @endfor

                    <!-- Next Page Link -->
                    <li class="page-item {{ ($games->currentPage() == $games->lastPage()) ? 'disabled' : '' }}">
                        <a class="page-link" href="{{ $games->nextPageUrl() }}">Next</a>
                    </li>
                </ul>
            @endif
        </div>
    </div>
@endsection
