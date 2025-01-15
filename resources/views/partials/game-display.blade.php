@if ($game)
    @if ((!Auth::check()) || (Auth::user()->role == '2' && Auth::user()->id != $game->id_seller))
        <!-- No Buttons: This section remains unchanged -->
        <div class="card mb-3 position-relative">
            <!-- Full clickable link -->
            <a href="{{ url('/games/' . $game->id) }}" class="stretched-link"></a>

            <div class="row g-0">
                <!-- Image Section -->
                <div class="col-md-3 d-flex align-items-center justify-content-center bg-secondary text-white"
                    style="width: 200px; height: 200px; border-top-left-radius: 15px; border-bottom-left-radius: 15px;">
                    @if($game->images && count($game->images) > 0)
                        <img src="{{ asset($game->images->first()->image_path) }}" alt="Game Image"
                            class="img-fluid img-thumbnail w-100 h-100" style="object-fit: contain;">
                    @else
                        <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid img-thumbnail w-100 h-100"
                            style="object-fit: cover;">
                    @endif
                </div>

                <!-- Game Details Section -->
                <div class="col-md-5">
                    <div class="card-body">
                        <h5 class="card-title"><b>{{ $game->name }}</b></h5>
                        @if ($game->categories->count() > 0)
                            <ul class="list-inline">
                                <li class="list-inline-item">Categories:</li>
                                @foreach ($game->categories as $category)
                                    <li class="list-inline-item">{{ $category->category_name }}</li>
                                @endforeach
                            </ul>
                        @else
                            <p>Categories: None</p>
                        @endif
                        @if ($game->operatingSystem)
                            <p class="mb-0">OS: {{ $game->operatingSystem->operatingsystem }}</p>
                        @else
                            <p class="mb-0">OS: Not specified</p>
                        @endif
                    </div>
                </div>

                <!-- Price and Buttons Section (Aligned to the right) -->
                <div class="col-md-4 d-flex justify-content-end align-items-center px-3">
                    <!-- Price Section (Aligned to the right) -->
                    <div class="text-start position-relative me-5" style="z-index: 10; width: auto;">
                        @if ($game->is_on_sale)
                            <div>
                                <span class="text-danger fs-4">{{ $game->discount_price }} €</span><br>
                                <span class="text-muted text-decoration-line-through">{{ $game->price }} €</span><br>
                                @php
                                    $discountPercentage = (($game->price - $game->discount_price) / $game->price) * 100;
                                @endphp
                                <span class="badge bg-danger">-{{ number_format($discountPercentage, 0) }}%</span>
                            </div>
                        @else
                            <div>
                                <span class="fs-4">{{ $game->price }} €</span>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    @else
        <!-- Buttons: This section gets updated -->
        <div class="card mb-3 position-relative">
            <!-- Full clickable link -->
            <a href="{{ url('/games/' . $game->id) }}" class="stretched-link"></a>

            <!-- Wishlist Button (Always at the top-right) -->
            @if(Auth::check() && (Auth::user()->role == '1'))
                <div class="position-absolute top-0 end-0 m-3" style="z-index: 100;">
                    @if (app('App\Http\Controllers\WishlistController')->isInWishlist($game->id))
                        <form action="{{ route('wishlist.remove', $game->id) }}" method="POST" class="w-100">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-outline-dark btn-sm p-0 rounded-circle"
                                style="width: 30px; height: 30px; display: flex; justify-content: center; align-items: center;">
                                <i class="fas fa-heart text-danger" style="font-size: 16px;"></i>
                            </button>
                        </form>
                    @else
                        <form action="{{ route('wishlist.add', $game->id) }}" method="POST" class="w-100">
                            @csrf
                            <button type="submit" class="btn btn-outline-dark btn-sm p-0 rounded-circle"
                                style="width: 30px; height: 30px; display: flex; justify-content: center; align-items: center;">
                                <i class="far fa-heart" style="font-size: 16px;"></i>
                            </button>
                        </form>
                    @endif
                </div>
            @endif

            <div class="row g-0">
                <!-- Image Section -->
                <div class="col-md-3 d-flex align-items-center justify-content-center bg-secondary text-white"
                    style="width: 200px; height: 200px; border-top-left-radius: 15px; border-bottom-left-radius: 15px;">
                    @if($game->images && count($game->images) > 0)
                        <img src="{{ asset($game->images->first()->image_path) }}" alt="Game Image"
                            class="img-fluid img-thumbnail w-100 h-100" style="object-fit: contain;">
                    @else
                        <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid img-thumbnail w-100 h-100"
                            style="object-fit: cover;">
                    @endif
                </div>

                <!-- Game Details Section -->
                <div class="col-md-5">
                    <div class="card-body">
                        <h5 class="card-title"><b>{{ $game->name }}</b></h5>
                        @if ($game->categories->count() > 0)
                            <ul class="list-inline">
                                <li class="list-inline-item">Categories:</li>
                                @foreach ($game->categories as $category)
                                    <li class="list-inline-item">{{ $category->category_name }}</li>
                                @endforeach
                            </ul>
                        @else
                            <p>Categories: None</p>
                        @endif
                        @if ($game->operatingSystem)
                            <p class="mb-0">OS: {{ $game->operatingSystem->operatingsystem }}</p>
                        @else
                            <p class="mb-0">OS: Not specified</p>
                        @endif
                    </div>
                </div>

                <!-- Price and Buttons Section (Aligned to the right) -->
                <div class="col-md-4 d-flex justify-content-end align-items-center px-3">
                    <!-- Price Section (Aligned to the right) -->
                    <div class="text-start position-relative me-5" style="z-index: 10; width: auto;">
                        @if ($game->is_on_sale)
                            <div>
                                <span class="text-danger fs-4">{{ $game->discount_price }} €</span><br>
                                <span class="text-muted text-decoration-line-through">{{ $game->price }} €</span><br>
                                @php
                                    $discountPercentage = (($game->price - $game->discount_price) / $game->price) * 100;
                                @endphp
                                <span class="badge bg-danger">-{{ number_format($discountPercentage, 0) }}%</span>
                            </div>
                        @else
                            <div>
                                <span class="fs-4">{{ $game->price }} €</span>
                            </div>
                        @endif
                    </div>

                    <!-- Buttons Section -->
                    <div class="d-flex flex-column align-items-start gap-2 position-relative"
                        style="z-index: 10; width: 150px;">
                        @if (Auth::check() && Auth::user()->role == '1')
                            <form action="{{ route('cart.add', $game->id) }}" method="POST" class="w-100">
                                @csrf
                                <button type="submit" class="btn btn-outline-dark btn-sm w-100">Add to Cart</button>
                            </form>
                        @endif

                        @if (Auth::check() && Auth::user()->role != '1' && Auth::user()->id == $game->id_seller || Auth::user()->role == '3')
                            <a href="{{ route('games.edit', $game->id) }}"
                                class="btn btn-outline-primary btn-sm w-100 mb-1">Edit</a>
                            <form action="{{ route('games.destroy', $game->id) }}" method="POST" class="w-100"
                                onsubmit="return confirm('Are you sure you want to delete this game?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-outline-danger btn-sm w-100">Delete</button>
                            </form>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    @endif
@endif
