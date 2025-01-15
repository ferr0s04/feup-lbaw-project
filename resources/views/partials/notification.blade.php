<div class="notification-item {{ $notification->isread ? 'read' : 'unread' }}">
    <form action="{{ route('notifications.destroy', $notification->id) }}" method="POST" style="position: absolute; top: 10px; right: 10px;">
        @csrf
        @method('DELETE')
        <button type="submit" class="delete-btn" style="background: none; border: none; cursor: pointer;">
            <i class="fa fa-trash" aria-hidden="true"></i>
        </button>
    </form>

    <p class="message">{{ $notification->message }}</p>
    <small class="date">{{ \Carbon\Carbon::parse($notification->notification_date)->format('d M Y H:i') }}</small>

    @if (!$notification->isread)
        <form action="{{ route('notifications.mark-as-read', $notification->id) }}" method="POST">
            @csrf
            @method('PATCH')
            <button type="submit" class="mark-as-read-btn">Mark as Read</button>
        </form>
    @endif
</div>
