<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Password;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use App\Mail\PasswordResetMail;

class PasswordResetController extends Controller
{
    // Show the form to request a password reset
    public function showResetRequestForm()
    {
        return view('auth.passwords.email');
    }

    // Send the reset link email
    public function sendResetLinkEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $token = Str::random(60);

        \DB::table('password_resets')->insert([
            'email' => $request->email,
            'token' => $token,
            'created_at' => now(),
        ]);

        Mail::to($request->email)->send(new PasswordResetMail($token));

        return back()->with('status', 'We have emailed your password reset link!');
    }

    // Show the password reset form
    public function showResetForm($token)
    {
        return view('auth.passwords.reset', ['token' => $token]);
    }

    // Reset the user's password
    public function reset(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|min:8|confirmed',
            'token' => 'required',
        ]);

        $reset = \DB::table('password_resets')->where('email', $request->email)->where('token', $request->token)->first();

        if (!$reset) {
            return back()->withErrors(['email' => 'This password reset link is invalid or expired.']);
        }

        $user = User::where('email', $request->email)->first();
        $user->password = Hash::make($request->password);
        $user->save();

        \DB::table('password_resets')->where('email', $request->email)->delete();

        return redirect()->route('login')->with('status', 'Your password has been reset!');
    }
}
