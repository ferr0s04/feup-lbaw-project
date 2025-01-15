@extends('layouts.app')

@section('title', $hasReviewed ? 'Edit Review' : 'Add Review')

@section('content')
<div class="container">
    <h1>{{ $hasReviewed ? 'Edit Your Review' : 'Add a Review' }}</h1>
    
    <p>
        Game: <strong>{{ $orderDetail->game->name }}</strong><br>
        Order Date: <strong>{{ \Carbon\Carbon::parse($orderDetail->order->order_date)->format('Y-m-d') }}</strong>
    </p>
    <form action="{{ route('reviews.save', [$orderDetail->id_order, $orderDetail->id_game]) }}" method="POST">
        @csrf
        
        <div class="mb-3">
            <label for="review_rating" required class="form-label">Rating:</label>
            <div id="star-rating" class="star-rating">
                @for ($i = 1; $i <= 5; $i++)
                    <span class="star" data-index="{{ $i }}">
                        @if ($hasReviewed && is_object($orderDetail) && $i <= $orderDetail->review_rating)
                            <i class="fa fa-star empty hidden"></i>
                            <i class="fa fa-star filled"></i>
                        @else
                            <i class="fa fa-star empty"></i>
                            <i class="fa fa-star filled hidden"></i>
                        @endif
                    </span>
                @endfor
            </div>
            <input type="hidden" name="review_rating" id="review_rating" 
                value="{{ $hasReviewed && is_object($orderDetail) ? $orderDetail->review_rating : '' }}" required>
        </div>

        <div class="mb-3">
            <label for="review_comment" class="form-label">Review Comment</label>
            <input name="review_comment" id="review_comment" class="form-control" value="{{ $hasReviewed && is_object($orderDetail) ? $orderDetail->review_comment : old('review_comment', '') }}">
        </div>

        <button type="submit" id="add-update-review" class="btn btn-primary">
            {{ $hasReviewed ? 'Update Review' : 'Submit Review' }}
        </button>
    </form>
    @if ($hasReviewed)
        {{-- Form for deleting the review --}}
        <form action="{{ route('reviews.delete', [$orderDetail->id_order, $orderDetail->id_game]) }}" method="POST" style="display: inline;">
            @csrf
            @method('DELETE')

            <button type="submit" id="delete-review" class="btn btn-danger" onclick="confirmDelete()">
                Delete Review
            </button>
        </form>
    @endif
</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const stars = document.querySelectorAll('.star');
        const ratingInput = document.getElementById('review_rating');

        function updateStars(rating) {
            stars.forEach((star, index) => {
                const filledStar = star.querySelector('.fa-star.filled');
                const emptyStar = star.querySelector('.fa-star.empty');
                
                if (index < rating) {
                    filledStar.classList.remove('hidden');
                    emptyStar.classList.add('hidden');
                } else {
                    filledStar.classList.add('hidden');
                    emptyStar.classList.remove('hidden');
                }
            });
            ratingInput.value = rating;
        }

        stars.forEach((star, index) => {
            star.addEventListener('click', function () {
                const rating = index + 1;
                updateStars(rating);
            });
        });

        const currentRating = parseInt(ratingInput.value || 0);
        updateStars(currentRating);
    });

    function confirmDelete() {
        if (confirm("Are you sure you want to delete your review? This action cannot be undone.")) {
            document.getElementById('delete-review-form').submit();
        }
    }
</script>
@endsection
