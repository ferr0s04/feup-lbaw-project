<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Wishlist;
use App\Models\Game;
use App\Models\Buyer;

class WishlistController extends Controller
{

    public function index()
    {
        if (!auth()->check()) {
            return redirect()->route('login');
        }
    
        $user = auth()->user();
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->back();
        }
    
        // Fetch purchased games
        $purchasedGames = [];
    
        if ($user->role === 1) {
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
    
        $wishlist = Wishlist::with('game')->where('id_buyer', auth()->id())->get();
    
        // Remove purchased games from wishlist
        foreach ($wishlist as $item) {
            if (array_key_exists($item->game->id, $purchasedGames)) {
                Wishlist::where('id_buyer', $buyer->id_user)
                    ->where('id_game', $item->game->id)
                    ->delete();
            }
        }
    
        $wishlist = Wishlist::with('game')->where('id_buyer', auth()->id())->get();
    
        if ($wishlist->isEmpty()) {
            return view('pages.wishlist', ['wishlist' => null]);
        }
    
        return view('pages.wishlist', compact('wishlist'));
    }    

    // Adds a game to the wishlist
    public function addToWishlist(Request $request, $game_id)
    {
        if (!auth()->check()) {
            return redirect()->route('login')->with('error', 'You need to be logged in to add a game to the wishlist.');
        }

        $user = auth()->user();

        if ($user->role == '2') {
            return redirect()->route('home')->with('error', 'Sellers cannot add items to the wishlist.');
        }

        $game = Game::find($game_id);

        if (!$game) {
            return redirect()->route('home')->with('error', 'Game not found.');
        }

        $existingGame = \App\Models\Wishlist::where('id_game', $game->id)
            ->where('id_buyer', $user->id)
            ->first();

        if ($existingGame) {
            return redirect()->back()->with('error', 'Game is already in your wishlist.');
        }

        \App\Models\Wishlist::insert([
            'id_game' => $game->id,
            'id_buyer' => $user->id,
        ]);

        return redirect()->back()->with('success', 'Game added to wishlist successfully!');
    }

    public function removeFromWishlist(Request $request, $game_id)
    {
        if (!auth()->check()) {
            return redirect()->route('login')->with('error', 'You need to be logged in to remove a game from the cart.');
        }

        $user = auth()->user();

        if ($user->role == '2') {
            return redirect()->route('home')->with('error', 'Sellers cannot remove items from the cart.');
        }

        $buyer = Buyer::where('id_user', $user->id)->first();

        if (!$buyer) {
            return redirect()->route('home')->with('error', 'Buyer not found.');
        }

        $game = Game::find($game_id);

        if (!$game) {
            return redirect()->route('home')->with('error', 'Game not found.');
        }

        Wishlist::deleteCK($buyer->id_user, $game->id);

        return redirect()->back()->with('success', 'Game removed from cart successfully!');
    }

    public function isInWishlist($game_id)
    {
        if (!auth()->check()) {
            return false;
        }

        $user = auth()->user();
        return Wishlist::where('id_buyer', $user->id)->where('id_game', $game_id)->exists();
    }

}