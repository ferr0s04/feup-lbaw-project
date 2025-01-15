@extends('layouts.app')

@section('content')
<form id="login-form" method="POST" action="{{ route('login') }}">
    <h3>Login</h3>
    {{ csrf_field() }}

    <label for="login">E-mail or Username</label>
    <input id="login" type="text" name="login" value="{{ old('login') }}" required autofocus>
    @if ($errors->has('login'))
        <span class="error">
          {{ $errors->first('login') }}
        </span>
    @endif

    <label for="password" >Password</label>
    <input id="password" type="password" name="password" required>
    @if ($errors->has('password'))
        <span class="error">
            {{ $errors->first('password') }}
        </span>
    @endif

    <label class="remember-me">
        <input type="checkbox" name="remember" {{ old('remember') ? 'checked' : '' }}> Remember Me
    </label>

    <button type="submit">
        Login
    </button>
    <a href="{{ route('register') }}">Register</a>

    <div class="password-recovery-link">
        <a href="{{ route('password.request') }}">Forgot your password?</a>
    </div>

    @if (session('success'))
        <p class="success">
            {{ session('success') }}
        </p>
    @endif
</form>
@endsection
