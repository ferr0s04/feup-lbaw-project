<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

use Illuminate\View\View;

use App\Models\User;
use App\Models\Buyer;
use App\Models\Seller;
use App\Models\ShoppingCart;


class RegisterController extends Controller
{
    /**
     * Display a login form.
     */
    public function showRegistrationForm(): View
    {
        return view('auth.register')->with('hideNav', true);;
    }

    /**
     * Register a new user.
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:250',
            'email' => 'required|email|max:250|unique:users',
            'password' => 'required|min:8|confirmed',
            'username' => [
                'required',
                'string',
                'max:150',
                'regex:/^[A-Za-z0-9_.]+$/', // Only letters, numbers, underscores, and dots
                'unique:users', // Ensure the username is unique
            ],
            'role' => 'required|int:1,2'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'username' => $request->username, // Save the username
            'role' => $request->role
        ]);

        switch ($request->role) {
            case '1': // Buyer
                Buyer::create([
                    'id_user' => $user->id,
                    'id_shoppingcart' => ShoppingCart::create()->id, // Create a shopping cart for the buyer
                ]);
                break;
    
            case '2': // Seller
                Seller::create([
                    'id_user' => $user->id,
                    'rating' => 0, // Default rating for new sellers
                    'totalsalesnumber'=>10,
                    'totalearned'=>10,
                ]);
                break;
        }

        $credentials = $request->only('email', 'password');
        Auth::attempt($credentials);
        $request->session()->regenerate();

        Auth::login($user);
        return redirect()->intended('/home')->withSuccess('Registration successful!');
    }
}
