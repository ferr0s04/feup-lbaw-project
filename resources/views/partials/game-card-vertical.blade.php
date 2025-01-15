<div class="game-card-vertical">
    <a href="{{ url('/games/' . $game->id) }}">
        <div class="game-card-main d-flex flex-column" style="height: 100%;">
            <!-- Game Thumbnail -->
            <div class="game-card-thumb" style="height: 250px; width: 100%">
                @if($game->images && count($game->images) > 0)
                    <img src="{{ asset($game->images->first()->image_path) }}" alt="Game Image"
                        class="img-fluid img-thumbnail" style="max-height: 250px; width: auto;">
                @else
                    <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid img-thumbnail"
                        style="height: 250px; width: 250px;">
                @endif
            </div>

            <!-- Game Details -->
            <div class="game-card-details d-flex flex-column" style="flex-grow: 1;">
                <h5 class="game-card-title">{{ $game->name }}</h5>
                <p class="game-card-os">{{ $game->operatingSystem->operatingsystem ?? 'Not available' }}</p>

                <!-- Empty flex-grow to push the price section to the bottom -->
                <div class="flex-grow-1"></div>

                <!-- Game Price Section -->
                <div class="game-card-price mt-auto">
                    @if ($game->is_on_sale)
                        <span class="text-danger fs-4">{{ $game->discount_price }} €</span><br>
                        <span class="text-muted text-decoration-line-through">{{ $game->price }} €</span><br>
                        @php
                            $discountPercentage = (($game->price - $game->discount_price) / $game->price) * 100;
                        @endphp
                        <span class="badge bg-danger">-{{ number_format($discountPercentage, 0) }}%</span>
                    @else
                        <span class="fs-4">{{ $game->price }} €</span>
                    @endif
                </div>
            </div>
        </div>

        <!-- Wishlist and Cart Actions -->
        @if (Auth::check() && (Auth::user()->role == '1'))
            <div class="game-card-actions">
                @if (app('App\Http\Controllers\WishlistController')->isInWishlist($game->id))
                    <form action="{{ route('wishlist.remove', $game->id) }}" method="POST"
                        class="btn btn-outline-dark p-0 d-flex align-items-center justify-content-center text-center text-dark mt-2 add-to-wishlist rounded-circle"
                        style="width: 30px; font-size: 16px; height: 30px;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn p-0 border-0 bg-transparent d-flex align-items-center justify-content-center w-100 h-100">
                            <i class="fas fa-lg fa-heart text-danger"></i>
                        </button>
                    </form>
                @else
                    <form action="{{ route('wishlist.add', $game->id) }}" method="POST"
                        class="btn btn-outline-dark p-0 d-flex align-items-center justify-content-center text-center text-dark mt-2 add-to-wishlist rounded-circle"
                        style="width: 30px; font-size: 16px; height: 30px;">
                        @csrf
                        <button type="submit" class="btn p-0 border-0 bg-transparent d-flex align-items-center justify-content-center w-100 h-100">
                            <i class="far fa-lg fa-heart"></i>
                        </button>
                    </form>
                @endif
                @if (Auth::check() && Auth::user()->role != '1')
                    <form action="{{ route('cart.add', $game->id) }}" method="POST" class="mt-2">
                        @csrf
                        <button type="submit" class="btn btn-outline-dark" disabled>Add to Cart</button>
                    </form>
                @else
                <form action="{{ route('cart.add', $game->id) }}" method="POST" class="mt-2">
                    @csrf
                    <button type="submit" class="btn btn-outline-dark">Add to Cart</button>
                </form>
                @endif
            </div>
        @endif
    </a>
</div>
