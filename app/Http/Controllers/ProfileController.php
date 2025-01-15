<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Game;
use App\Models\Seller;
use App\Models\Buyer;
use App\Models\GameOrderDetails;

class ProfileController extends Controller
{
    public function showProfile($id)
    {
        $user = User::findOrFail($id);

        $purchasedGames = [];
        $orders = null;

        if ($user->role === 1) { // Buyer
            $buyer = $user->buyer;
            if ($buyer) {
                $orders = $buyer->orders()->with('gameOrderDetails.game')->get();
        
                foreach ($orders as $order) {
                    foreach ($order->gameOrderDetails as $gameDetail) {
                        $game = $gameDetail->game;
        
                        if (!isset($purchasedGames[$game->id])) {
                            $game->gameReview = $gameDetail;
                            $game->hasReviewed = $gameDetail->review_rating !== null;
                            $purchasedGames[$game->id] = $game;
                        }
                    }
                }
            }
        }

        // Seller-specific data
        $seller = null;
        if ($user->role === 2) { // Seller
            $seller = $user->seller;
        }

        // Return the profile view with the additional data
        return view('pages.profile', compact('user', 'purchasedGames', 'seller'))->with('hideNav', true);
    }


    public function updateProfile(Request $request, $id)
    {
            $user = User::findOrFail($id);
        
            // Validate input
            $validated = $request->validate([
                'username' => 'required|string|max:255',
                'bio' => 'nullable|string|max:500',
                'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);
        
            // Update fields
            $user->username = $validated['username'];
            $user->bio = $validated['bio'] ?? $user->bio; // tirar segunda parte se for suposto aceitar bios vazias
        
            // Handle profile picture upload
            if ($request->hasFile('profile_picture')) {
                $path = $request->file('profile_picture')->store('profile_pictures', 'public');
                $user->profile_picture = $path;
            }
        
            $user->save();
        
            return redirect()->route('profile', $user->id)->with('success', 'Profile updated successfully!');
        
    }

    public function updatePicture(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'profile_picture' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048', // Validate the file
        ]);

        // Handle the file upload
        if ($request->hasFile('profile_picture')) {
            // Delete the old picture if it exists
            if ($user->profile_picture) {
                Storage::delete('public/' . $user->profile_picture);
            }

            // Save the new picture
            $path = $request->file('profile_picture')->store('profile_pictures', 'public');
            $user->profile_picture = $path;
            $user->save(); // Save the user's updated picture path
        }

        // Return the new picture URL as JSON
        return response()->json([
            'success' => true,
            'picture_url' => asset('storage/' . $user->profile_picture),
        ]);
    }

    public function editProfile($id)
    {
        $user = User::findOrFail($id);
        return view('pages.profile-edit', compact('user'))->with('hideNav', true);;
    }

    public function deleteAccount($id)
    {
        $user = User::findOrFail($id);

        // Delete related notifications
        if ($user->notifications()->exists()) {
            $user->notifications()->delete(); // Adjust based on your relationships
        }

        // Handle role-specific deletions
        if ($user->role === 1) { // Buyer
            $buyer = $user->buyer;
            if ($buyer) {
                foreach ($buyer->orders as $order) {
                    foreach ($order->gameOrderDetails as $detail) {
                        if ($detail && $detail->id_order && $detail->id_game) {
                            GameOrderDetails::where('id_order', $detail->id_order)
                                ->where('id_game', $detail->id_game)
                                ->delete();
                        }
                    }
                    $order->delete(); // Delete orders
                }
                $buyer->delete(); // Delete buyer
            }
        } elseif ($user->role === 2) { // Seller
            $seller = $user->seller;
            if ($seller) {
                foreach ($seller->games as $game) {
                    $game->delete(); // Delete games
                }
                $seller->delete(); // Delete seller
            }
        }

        // Delete profile picture if it exists
        if ($user->profile_picture) {
            Storage::delete('public/' . $user->profile_picture);
        }

        // Delete user account
        $user->delete();

        // Logout the user
        auth()->logout();

        return redirect('/')->with('success', 'Your account has been deleted successfully.');
    }

    public function orderHistory($id)
    {
        $user = User::findOrFail($id);
        
        if ($user->role === 1) { // Buyer
            $orders = $user->buyer->orders()->with('gameOrderDetails.game')->get();
        } else {
            // Redirect back or show an error if the user is not a buyer
            return redirect()->route('profile', $id)->with('error', 'This user does not have order history.');
        }

        return view('pages.order-history', compact('orders')); // Pass orders to the view
    }
}

