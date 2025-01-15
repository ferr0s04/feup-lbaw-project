@extends('layouts.app')

@section('content')
<div class="container mt-4">
    <h1 class="text-center mb-4">Your Messages</h1>

    @if ($conversations->isEmpty())
        <p class="text-center">No support messages found.</p>
    @else
        @foreach($conversations->groupBy('game.name') as $gameName => $gameConversations)
            <div class="game-conversations mb-4 p-3 border rounded bg-white">
                <h3 class="text-primary">Game: {{ $gameName }}</h3>

                @foreach($gameConversations as $conversation)
                    <div class="conversation mb-3 p-3 border rounded bg-light">
                        <h5>Conversation with {{ $conversation->seller->user->name }}</h5>
                        <ul class="list-unstyled">
                            @foreach($conversation->messages as $message)
                                <li class="mb-2">
                                    <strong>{{ ucfirst($message->sender_role) }}:</strong> {{ $message->response_message }}
                                    <br>
                                    <small class="text-muted"><em>{{ $message->response_date }}</em></small>
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
                @endforeach
            </div>
        @endforeach
    @endif
</div>
@endsection
