@extends('layouts.app')

@section('content')
<div class="container">
    <h1 class="text-center mb-4">Your Messages</h1>

    @if ($conversations->isEmpty())
        <p class="text-muted text-center">No support messages found.</p>
    @else
        @foreach($conversations as $conversation)
            <div class="card mb-4 shadow-sm">
                <div class="card-header bg-dark text-white">
                    <h5 class="mb-0">
                        Conversation about 
                        <strong>{{ $conversation->game->name ?? 'Unknown Game' }}</strong>
                        with {{ $conversation->buyer->user->name }}
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-group mb-3">
                        @foreach($conversation->messages as $message)
                            <li class="list-group-item">
                                <strong>{{ ucfirst($message->sender_role) }}:</strong> 
                                {{ $message->response_message }}
                                <br>
                                <small class="text-muted">{{ $message->response_date }}</small>
                            </li>
                        @endforeach
                    </ul>

                    <!-- Form para enviar mensagens -->
                    <form method="POST" action="{{ route('customer-support.addMessage', $conversation->id) }}">
                        @csrf
                        <div class="form-group">
                            <textarea name="response_message" class="form-control" rows="2" placeholder="Write a message..."></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm mt-2">Send</button>
                    </form>
                </div>
            </div>
        @endforeach
    @endif
</div>
@endsection
