@extends('layouts.app')

@section('content')
    <div class="reset-container">
        <h1>Reset Your Password</h1>
        <form method="POST" action="{{ route('password.update') }}">
            @csrf
            <input type="hidden" name="token" value="{{ $token }}">
            
            <label for="email">Email Address</label>
            <input id="reset-email" type="email" name="email" value="{{ old('email') }}" required autofocus>
            
            <label for="password">New Password</label>
            <input id="reset-password" type="password" name="password" required>
            
            <label for="password_confirmation">Confirm Password</label>
            <input id="reset-password_confirmation" type="password" name="password_confirmation" required>
            
            @error('email')
                <div class="error">{{ $message }}</div>
            @enderror

            @error('password')
                <div class="error">{{ $message }}</div>
            @enderror

            <button type="submit">Reset Password</button>
        </form>

        <div class="form-footer">
            <a href="{{ route('login') }}">Back to Login</a>
        </div>
    </div>
@endsection
