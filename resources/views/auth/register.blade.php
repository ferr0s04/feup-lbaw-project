@extends('layouts.app')

@section('content')
<form id="register-form" method="POST" action="{{ route('register') }}">
  <h3>Sign Up</h3>
    {{ csrf_field() }}

    <label for="name">Name</label>
    <input id="name" type="text" name="name" value="{{ old('name') }}" required autofocus>
    @if ($errors->has('name'))
      <span class="error">
          {{ $errors->first('name') }}
      </span>
    @endif

    <label for="email">E-Mail Address</label>
    <input id="email" type="email" name="email" value="{{ old('email') }}" required>
    @if ($errors->has('email'))
      <span class="error">
          {{ $errors->first('email') }}
      </span>
    @endif

    <label for="password">Password</label>
    <input id="password" type="password" name="password" required>
    @if ($errors->has('password'))
      <span class="error">
          {{ $errors->first('password') }}
      </span>
    @endif

    <label for="password-confirm">Confirm Password</label>
    <input id="password-confirm" type="password" name="password_confirmation" required>

    <label for="username">Username</label>
    <input id="username" type="text" name="username" value="{{ old('username') }}" required autofocus>
    @if ($errors->has('username'))
      <span class="error">
          {{ $errors->first('username') }}
      </span>
    @endif

    <label for="role">Register as:</label>
    <select id="role" name="role" required>
        <option value="" disabled selected>Choose a role</option>
        <option value='1' {{ old('role') == '1' ? 'selected' : '' }}>Buyer</option>
        <option value='2' {{ old('role') == '2' ? 'selected' : '' }}>Seller</option>
    </select>
    @if ($errors->has('role'))
      <span class="error">
          {{ $errors->first('role') }}
      </span>
    @endif

    <button type="submit">
      Register
    </button>
    <a href="{{ route('login') }}" >Login</a>
</form>
@endsection