@extends('layouts.app')

@section('content')
<div class="profile-container py-5">
    <!-- Profile Header -->
    <div class="profile-header d-flex align-items-center">
        <div class="profile-picture me-4">
            <img id="profilePicturePreview" 
                src="{{ $user->profile_picture ? asset('storage/' . $user->profile_picture) : asset('img/noprofileimage.png') }}" 
                alt="{{ $user->name }}" 
                class="rounded-circle border"
                style="width: 150px; height: 150px; object-fit: cover;">
        </div>
        <div>
            <h1 class="mb-0">{{ $user->username }}</h1>
            <p class="text-muted">{{ $user->bio ?? 'No bio available.' }}</p>
        </div>
        <div class="ms-auto">
            <a href="{{ route('profile.edit', $user->id) }}" class="btn btn-custom me-2">Edit Profile</a>
            @if(session('success'))
            <div class="alert alert-success">
                {{ session('success') }}
            </div>
            @endif
        </div>
    </div>
    @if($user->role === 1)
        <div class="notifications-orders">
            <a href="/notifications" class="btn btn-custom me-2">Notifications</a>
            <a href="{{ route('order-history', $user->id) }}" class="btn btn-custom me-2">Order History</a>
        </div>
    @elseif($user->role === 2)
        <div class="notifications-orders">
            <a href="/notifications" class="btn btn-custom me-2">Notifications</a>
        </div>
    @endif

    <!-- User Role Specific Section -->
    <hr class="my-4">
    @if($user->role === 1) {{-- Buyer Section --}}
        <h2>Purchased Games</h2>
        @if (collect($purchasedGames)->isEmpty())
            <p class="text-muted">You haven't purchased any games yet.</p>
        @else
            <div class="row">
                @foreach ($purchasedGames as $game)
                <div class="col-md-4 mb-4">
                    <div class="card h-100 shadow-sm">
                        <!-- Game Image -->
                        <a href="{{ url('/games/' . $game->id) }}" class="text-decoration-none">
                            <div class="card-img-top" style="height: 200px; overflow: hidden;">
                                @if($game->images && count($game->images) > 0)
                                    <img src="{{ asset($game->images->first()->image_path) }}" alt="{{ $game->name }}"
                                        class="img-fluid w-100" style="object-fit: cover; height: 100%;">
                                @else
                                    <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid w-100" style="object-fit: cover; height: 100%;">
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
                                @if ($game->categories->count() > 0)
                                    {{ $game->categories->pluck('category_name')->join(', ') }}
                                @else
                                    None
                                @endif
                            </p>
                            <p class="text-muted">OS: {{ $game->operatingSystem->operatingsystem ?? 'Not specified' }}</p>
                        </div>
                        <!-- Review Button -->
                        <div class="card-footer text-center">
                            @if (!$user->is_review_blocked)
                                @if ($game->hasReviewed)
                                    <a href="{{ route('reviews.edit', [$game->gameReview->id_order, $game->id]) }}" class="btn btn-warning btn-sm">Edit Review</a>
                                @else
                                    @php
                                        $orderDetail = $game->gameOrderDetails->firstWhere('order.id_buyer', auth()->user()->id);
                                    @endphp
                                    @if ($orderDetail)
                                        <a href="{{ route('reviews.add', [$orderDetail->id_order, $game->id]) }}" class="btn btn-primary btn-sm">Add Review</a>
                                    @else
                                        <span class="text-muted">You have not purchased this game.</span>
                                    @endif
                                @endif
                            @else
                                <span class="text-muted">Reviewing is disabled for this user.</span>
                            @endif
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        @endif
    @elseif($user->role === 2) {{-- Seller Section --}}
        <h2>Seller Dashboard</h2>
        <div class="card shadow-sm p-4">
            <p><strong>Total Sales Number:</strong> {{ $seller->total_sales_number }}</p>
            <p><strong>Total Earned:</strong> ${{ number_format($seller->total_earned, 2) }}</p>
            <p><strong>Rating:</strong> {{ number_format($seller->rating, 1) }} / 5</p>
        </div>
    @endif
</div>

@endsection
