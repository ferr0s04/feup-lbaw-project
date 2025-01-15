@extends('layouts.app')

@section('game-info')
@if($purchasedGame)
    <div class="alert alert-info">
        <p>You purchased this game on <strong>{{ $purchasedGame->order->order_date->format('Y-m-d') }}</strong>.</p>

        @if ($isReviewBlocked)
            <p class="text-danger">You are blocked from adding any reviews.</p>
        @else
            @if ($hasReviewed)
                <a href="{{ url('/reviews/edit/' . $purchasedGame->id_order . '/' . $purchasedGame->id_game) }}"
                   class="btn btn-warning">Edit Review</a>
            @else
                <a href="{{ url('/reviews/add/' . $purchasedGame->id_order . '/' . $purchasedGame->id_game) }}"
                   class="btn btn-primary">Add Review</a>
            @endif
        @endif
    </div>
@endif
<h1>{{ $game->name }}</h1>
<div class="game-info-top">
    <div class="product-image-carousel">
        <div id="carousel-{{ $game->id }}" class="carousel">
            @foreach ($game->images as $index => $image)
                <div class="carousel-item {{ $index === 0 ? 'visible' : '' }}">
                    <img src="{{ asset($image->image_path) }}" alt="{{ $game->name }}">
                </div>
            @endforeach
            @forelse ($game->images as $index => $image)
            @empty
                <div class="carousel-item visible">
                    <img src="{{ asset('img/noimage.jpg') }}" alt="Default Image">
                </div>
            @endforelse
        </div>

        @if (count($game->images) > 1)
            <button class="carousel-control prev" onclick="prevImage({{ $game->id }})">❮</button>
            <button class="carousel-control next" onclick="nextImage({{ $game->id }})">❯</button>
        @endif
    </div>
    <div class="product-details">
        <div class="other-product-details">
            <p><strong>Release Date:</strong> {{ $game->release_date->format('d M Y') }}</p>
            <div class="game-rating">
                <div class="star-rating" data-rating="{{ $game->rating }}">
                    <strong>Rating:&nbsp;</strong>
                    @for ($i = 1; $i <= 5; $i++)
                        @if ($i <= floor($game->rating))
                            <!-- Full stars -->
                            <span class="fa fa-star filled"></span>
                        @elseif ($i == ceil($game->rating))
                            <!-- Fractional star -->
                            <span class="fa fa-star fractional">
                                <span class="fa fa-star filled"
                                    style="width: {{ ($game->rating - floor($game->rating)) * 100 }}%;"></span>
                            </span>
                        @else
                            <!-- Empty stars -->
                            <span class="fa fa-star"></span>
                        @endif
                    @endfor
                    <strong>&nbsp;{{ number_format($game->rating, 1) }}</strong>
                </div>
            </div>

            @if ($game->stock <= 0)
                <p><strong>Stock:</strong> <span class="text-danger">Out of Stock</span></p>
            @else
                <p><strong>Stock:</strong> {{ $game->stock }} available</p>
            @endif
        </div>
        
        @if ($game->is_on_sale)
            <div class="game-info-price">
                <p><strong>Price:</strong><span class="text-danger"> {{ $game->discount_price }} €&nbsp;&nbsp;</span><br>
                </p>
                <span class="text-muted text-decoration-line-through">{{ $game->price }} €</span><br>
                @php
                    $discountPercentage = (($game->price - $game->discount_price) / $game->price) * 100;
                @endphp
                <p>&nbsp;&nbsp;</p>
                <span class="badge bg-danger">-{{ number_format($discountPercentage, 0) }}%</span>
            </div>
        @else
            <p><strong>Price:</strong> €{{ number_format($game->price, 2) }}</p>
        @endif
    </div>

    <div class="game-actions">
        @if(Auth::check() && (Auth::user()->role == '1'))
            @if (app('App\Http\Controllers\WishlistController')->isInWishlist($game->id))
                <div class="d-flex justify-content-end">
                    <form action="{{ route('wishlist.remove', $game->id) }}" method="POST">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-outline-dark btn-sm p-0 rounded-circle"
                            style="width: 30px; height: 30px; display: flex; justify-content: center; align-items: center;">
                            <i class="fas fa-lg fa-heart text-danger"></i>
                        </button>
                    </form>
                </div>
            @else
                <div class="d-flex justify-content-end">
                    <form action="{{ route('wishlist.add', $game->id) }}" method="POST">
                        @csrf
                        <button type="submit" class="btn btn-outline-dark btn-sm p-0 rounded-circle"
                            style="width: 30px; height: 30px; display: flex; justify-content: center; align-items: center;">
                            <i class="far fa-lg fa-heart"></i>
                        </button>
                    </form>
                </div>
            @endif
        @endif

        <div class="purchase-box">
            <p><strong>Seller:</strong> {{ $game->seller->user->name }}</p>

            <div class="purchase-actions">
                @if ($game->stock <= 0 || (Auth::check() && Auth::user()->role != '1'))
                    <!-- Disable the Add to Cart and Buy Now buttons if the stock is 0 -->
                    <button class="btn add-to-cart" disabled>Add to Cart</button>
                    <button class="btn buy-now" disabled>Buy Now</button>
                @else
                    @if (!Auth::check() || (Auth::check() && Auth::user()->role == '1'))
                        <form id="add-to-cart-form-{{ $game->id }}" action="{{ route('cart.add', $game->id) }}" method="POST">
                            @csrf
                            <button type="submit" class="btn add-to-cart">Add to Cart</button>
                        </form>
                        <form action="{{ route('buy.now') }}" method="POST">
                            @csrf
                            <input type="hidden" name="game_id" value="{{ $game->id }}">
                            <button type="submit" class="btn buy-now">Buy Now</button>
                        </form>
                        <div class="support-section">
                            <a href="{{ route('support.conversation.start', ['gameId' => $game->id]) }}"
                                class="btn btn-info">Support</a>
                        </div>
                    @endif
                @endif
            </div>
        </div>
    </div>
</div>
<div class="game-description">
    <h3>Description</h3>
    <p>{{ $game->description }}</p>
</div>
<div class="additional-details">
    <h3>Specifications</h3>
    <ul>
        <li><strong>Operating System:</strong> {{ $game->operatingSystem->operatingsystem ?? 'Not available' }}</li>
        @if (!isset($game->operatingSystem->id) || $game->operatingSystem->id < 31 || $game->operatingSystem->id > 40)
            <li><strong>Memory RAM:</strong> {{ $game->memoryRAM->memoryram ?? 'Not available' }}</li>
            <li><strong>Processor:</strong> {{ $game->processor->processor ?? 'Not available' }}</li>
            <li><strong>Graphics Card:</strong> {{ $game->graphicsCard->graphicscard ?? 'Not available' }}</li>
            <li><strong>Storage:</strong> {{ $game->storage->storage ?? 'Not available' }}</li>
        @endif
    </ul>
</div>
<div class="game-reviews">
    <h3>Reviews</h3>
    <!-- Sorting Form -->
    <form method="GET" action="{{ route('games.showinfo', $game->id) }}">
        <label for="sort_by">Sort by:</label>
        <select name="sort_by" id="sort_by" onchange="this.form.submit()">
            <option value="date_desc" {{ $sortBy == 'date_desc' ? 'selected' : '' }}>Date (Newest first)</option>
            <option value="date_asc" {{ $sortBy == 'date_asc' ? 'selected' : '' }}>Date (Oldest first)</option>
            <option value="rating_desc" {{ $sortBy == 'rating_desc' ? 'selected' : '' }}>Rating (Highest first)</option>
            <option value="rating_asc" {{ $sortBy == 'rating_asc' ? 'selected' : '' }}>Rating (Lowest first)</option>
        </select>
    </form>
    @if($game->reviews->isEmpty())
        <p>No reviews available for this game.</p>
    @else
        <ul>
            @foreach($filteredReviews as $review)
                <li>
                    <div class="review-rating">
                        <strong>Rating:</strong>
                        <div class="star-rating" data-rating="{{ $review->review_rating }}">
                            @for ($i = 1; $i <= 5; $i++)
                                <span class="fa fa-star {{ $i <= $review->review_rating ? 'filled' : '' }}"></span>
                            @endfor
                            <strong>&nbsp;{{ $review->review_rating }}.0</strong>
                        </div>
                    </div>

                    <strong>Comment:</strong> {{ $review->review_comment ?? 'No comment provided.' }}<br>

                    <strong>Date:</strong> {{ $review->review_date->format('d M Y') }}
                </li>
            @endforeach
        </ul>
        <!-- Pagination -->
        <div class="d-flex justify-content-center mt-4">
            @if ($filteredReviews->lastPage() > 1)
                <ul class="pagination">
                    <!-- Previous Page Link -->
                    <li class="page-item {{ ($filteredReviews->currentPage() == 1) ? 'disabled' : '' }}">
                        <a class="page-link" href="{{ $filteredReviews->previousPageUrl() }}">Previous</a>
                    </li>

                    <!-- Page Numbers -->
                    @php
                        $currentPage = $filteredReviews->currentPage();
                        $lastPage = $filteredReviews->lastPage();
                        $rangeStart = max(1, $currentPage - 2);
                        $rangeEnd = min($lastPage, $currentPage + 2);
                    @endphp

                    @for ($i = $rangeStart; $i <= $rangeEnd; $i++)
                        <li class="page-item {{ ($filteredReviews->currentPage() == $i) ? 'active' : '' }}">
                            <a class="page-link" href="{{ $filteredReviews->url($i) }}">{{ $i }}</a>
                        </li>
                    @endfor

                    <!-- Next Page Link -->
                    <li class="page-item {{ ($filteredReviews->currentPage() == $filteredReviews->lastPage()) ? 'disabled' : '' }}">
                        <a class="page-link" href="{{ $filteredReviews->nextPageUrl() }}">Next</a>
                    </li>
                </ul>
            @endif
        </div>
    @endif
</div>

@endsection
