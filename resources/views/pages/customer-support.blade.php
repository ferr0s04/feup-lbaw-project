@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Support</h1>
    <p>If you have any questions or need help, feel free to contact us below.</p>

    @if(session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <form method="POST" action="{{ route('customer-support.store') }}" class="customer-support-form">
        @csrf
        <div class="form-group">
            <label for="message">Your Message:</label>
            <textarea name="message" id="message" class="form-control" rows="5" required></textarea>
        </div>

        <div class="form-group">
            <label for="type">Category:</label>
            <select name="type" id="type" class="form-control" required>
                <option value="CS">Customer Service</option>
                <option value="GS">Game Support</option>
            </select>
        </div>

        <button type="submit" class="btn btn-primary mt-3">Send</button>
    </form>
</div>
@endsection
