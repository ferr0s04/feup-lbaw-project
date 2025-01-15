<?php
 
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

use Illuminate\View\View;
use Illuminate\Support\Facades\Log;

class LoginController extends Controller
{

    /**
     * Display a login form.
     */
    public function showLoginForm()
    {
        if (Auth::check()) {
            return redirect('/');
        } else {
            return view('auth.login')->with('hideNav', true);        }
    }

    /**
     * Handle an authentication attempt.
     */
    public function authenticate(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'login' => ['required'], // Accept either email or username
            'password' => ['required'],
        ]);

        $loginField = filter_var($credentials['login'], FILTER_VALIDATE_EMAIL) ? 'email' : 'username';

        if (Auth::attempt([$loginField => $credentials['login'], 'password' => $credentials['password']], $request->filled('remember'))) {
            $request->session()->regenerate();
            $user = Auth::user();

            // Check if the user is an admin
            if ($user->role === 3) {
                return redirect()->route('admin.console'); // Redirect to admin console
            }

            return redirect()->intended('/home');
        }

        return back()->withErrors([
            'login' => 'The provided credentials do not match our records.',
        ])->onlyInput('login');
    }

    /**
     * Log out the user from application.
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('login')
            ->withSuccess('You have logged out successfully!');
    } 
}
