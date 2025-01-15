@foreach ($games as $game)
    <a href="{{ url('/games/' . $game->id) }}" class="card mb-3 text-decoration-none">
        <div class="row g-0">
            <!-- Image Section -->
            <div class="col-md-3 d-flex align-items-center justify-content-center bg-secondary text-white" style="width: 200px; height: 200px; border-top-left-radius: 15px; border-bottom-left-radius: 15px;">
                @if($game->images && count($game->images) > 0)
                    <img src="{{ asset($game->images->first()->image_path) }}" alt="Game Image"
                        class="img-fluid img-thumbnail w-100 h-100" style="object-fit: contain;">
                @else
                    <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid img-thumbnail w-100 h-100" style="object-fit: cover;">
                @endif
            </div>
            <!-- Game Details Section -->
            <div class="col-md-6">
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
                        <ul class="list-inline">
                            <li class="list-inline-item">Categories: None</li>
                        </ul>
                    @endif
                    @if ($game->operatingSystem)
                        <ul class="list-inline">
                            <li class="list-inline-item">OS:</li>
                            <li class="list-inline-item">{{ $game->operatingSystem->operatingsystem }}</li>
                        </ul>
                    @else
                        <ul class="list-inline">
                            <li class="list-inline-item">OS: Not specified</li>
                        </ul>
                    @endif
                </div>
            </div>

            <!-- Price Section -->
            <div class="col-md-3 d-flex align-items-center justify-content-center">
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
                    <span class="fs-4">{{ $game->price }} €</span><br>
                @endif
            </div>
        </div>
    </a>
@endforeach