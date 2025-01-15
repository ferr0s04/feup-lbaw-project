@extends('layouts.app')

@section('content')
<div class="notifications-container">
    <h1>Your Notifications</h1>

    @if ($notifications->isEmpty())
        <p>No notifications to display.</p>
    @else
        <form action="{{ route('notifications.mark-all-as-read') }}" method="POST">
            @csrf
            <button type="submit" class="mark-all-as-read-btn btn btn-primary">Mark All as Read</button>
        </form>

        @foreach ($notifications as $notification)
            @include('partials.notification', ['notification' => $notification])
        @endforeach
    @endif
</div>

@endsection
