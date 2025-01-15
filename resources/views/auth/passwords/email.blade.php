@extends('layouts.app')

@section('content')
    <div class="email-container">
        <h1>Password Reset</h1>
        <form method="POST" action="{{ route('password.email') }}">
            @csrf
            <label for="email">Email Address</label>
            <input id="recover-email" type="email" name="email" value="{{ old('email') }}" required autofocus>
            @error('email')
                <div class="error">{{ $message }}</div>
            @enderror
            <button type="submit">Send Password Reset Link</button>
        </form>
    </div>
@endsection
