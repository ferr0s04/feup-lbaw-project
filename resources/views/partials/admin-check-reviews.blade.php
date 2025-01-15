@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Reviews by {{ $user->name }}</h1>
    
    <!-- Block/Unblock Button -->
    <form action="{{ route('admin.toggleReviewBlock', $user->id) }}" method="POST" style="display:inline;">
        @csrf
        @method('PATCH')
        <button type="submit" class="btn {{ $user->is_review_blocked ? 'btn-success' : 'btn-danger' }} mb-3">
            {{ $user->is_review_blocked ? 'Unblock Reviews' : 'Block Reviews' }}
        </button>
    </form>

    @if ($reviews->isEmpty())
        <p>This user has not made any reviews.</p>
    @else
        <div class="list-group">
            @foreach ($reviews as $review)
                <div class="list-group-item d-flex justify-content-between align-items-start">
                    <!-- Game Image -->
                    <a href="{{ url('/games/' . $review->game->id) }}" class="text-decoration-none me-3">
                        <div class="rounded overflow-hidden" style="width: 100px; height: 100px;">
                            @if($review->game->images && count($review->game->images) > 0)
                                <img src="{{ asset($review->game->images->first()->image_path) }}" alt="{{ $review->game->name }}"
                                    class="img-fluid w-100 h-100" style="object-fit: cover;">                
                            @else
                                <img src="/img/noimage.jpg" alt="Default Image" class="img-fluid w-100 h-100" style="object-fit: cover;">
                            @endif
                        </div>
                    </a>
                    <!-- Review Content -->
                    <div class="flex-grow-1">
                        <h5 class="mb-2 text-primary">{{ $review->game->name }}</h5>
                        
                        <!-- Star Rating -->
                        <div class="review-rating mb-2">
                            <strong>Rating:</strong>
                            <div class="star-rating">
                                @for ($i = 1; $i <= 5; $i++)
                                    <span class="fa fa-star {{ $i <= $review->review_rating ? 'text-warning' : 'text-muted' }}"></span>
                                @endfor
                                <strong>&nbsp;{{ $review->review_rating }}.0</strong>
                            </div>
                        </div>

                        <!-- Comment and Date -->
                        <p class="mb-2"><strong>Comment:</strong> {{ $review->review_comment ?? 'No comment provided.' }}</p>
                        <small class="text-muted"><strong>Date:</strong> {{ \Carbon\Carbon::parse($review->review_date)->format('d M Y') }}</small>
                    </div>

                    <!-- Edit and Delete Buttons -->
                    <div class="ms-3">
                        <!-- Edit Review Button -->
                        <a href="{{ route('reviews.edit', [$review->id_order, $review->id_game]) }}" class="btn btn-warning btn-sm me-2">
                            <i class="fa fa-pencil"></i>
                        </a>
                        
                        <!-- Delete Review Button -->
                        <form action="{{ route('reviews.delete', ['id_order' => $review->id_order, 'id_game' => $review->id_game]) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this review?');">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger btn-sm">
                                <i class="fa fa-trash"></i>
                            </button>
                        </form>
                    </div>
                </div>
            @endforeach
        </div>
    @endif

    <a href="{{ route('admin.console') }}" class="btn btn-secondary mt-3">Back to Admin Console</a>
</div>
@endsection
