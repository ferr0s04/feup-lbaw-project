@extends('layouts.app')

@section('content')
<div class="container mt-4">
    <h1 class="text-center mb-4">Conversation with {{ auth()->user()->role == 1 ? $conversation->seller->user->name : $conversation->buyer->user->name }}</h1>

    <div class="card shadow-sm">
        <div class="card-body">
            <ul class="list-group mb-4">
                @foreach ($conversation->messages as $message)
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div>
                            <strong class="text-primary">{{ ucfirst($message->sender_role) }}:</strong> 
                            {{ $message->response_message }}
                        </div>
                        <small class="text-muted">{{ $message->response_date }}</small>
                    </li>
                @endforeach
            </ul>

            <!-- Form para enviar mensagens -->
            <form method="POST" action="{{ route('support.message.addMessage', $conversation->id) }}" class="d-flex">
                @csrf
                <textarea name="response_message" class="form-control me-2" rows="2" placeholder="Write a message..."></textarea>
                <button type="submit" class="btn btn-custom me-2">Send</button>
            </form>
        </div>
    </div>
</div>
@endsection
