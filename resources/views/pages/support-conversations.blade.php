@extends('layouts.app')

@section('content')
<div class="container py-4">
    <h1 class="mb-4 text-center">Your Messages</h1>

    @if ($conversations->isEmpty())
        <div class="alert alert-info text-center">
            <p>No support messages found.</p>
        </div>
    @else
        <div class="row">
            @foreach($conversations as $conversation)
                <div class="col-md-6 mb-4">
                    <div class="card shadow-sm">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">
                                Conversation with 
                                @if (auth()->user()->role == 1) <!-- Buyer -->
                                    {{ $conversation->seller->user->name }}
                                @else <!-- Seller -->
                                    {{ $conversation->buyer->user->name }}
                                @endif
                            </h5>
                        </div>
                        <div class="card-body">
                            <p>
                                <strong>Last Message:</strong> 
                                {{ $conversation->messages->last()->response_message ?? 'No messages yet' }}
                            </p>
                            <p>
                                <strong>Date:</strong> 
                                {{ $conversation->messages->last()->response_date ?? $conversation->start_date }}
                            </p>
                            <form method="POST" action="{{ route('support.message.add', $conversation->id) }}">
                                @csrf
                                <textarea name="response_message" class="form-control mb-2" rows="2" placeholder="Write a message"></textarea>
                                <button type="submit" class="btn btn-custom me-2">Send</button>
                            </form>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
</div>
@endsection
