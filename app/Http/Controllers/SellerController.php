<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Game;
use App\Models\Category;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\GameOrderDetails;

class SellerController extends Controller
{

    public function show($id, Request $request)
    {
        try {
            // Ensure the game exists and fetch the seller
            $game = Game::with(['categories', 'images'])->findOrFail($id);
            $seller = User::where('id', $game->id_seller)->where('role', 2)->first();

            if (!$seller) {
                return redirect()->route('seller.home')->with('error', 'Seller not found.');
            }

            // Fetch the seller's games and categories
            $sellerGames = Game::with(['categories', 'images'])->where('id_seller', $seller->id)->get();
            if(Auth::user()->role == 3) {
                $sellerGames = Game::with(['categories', 'images'])->get();
            }
            $categories = Category::all();

            // Fetch purchase history with pagination
            $query = $request->input('query');
            $purchaseHistory = GameOrderDetails::where('id_game', $id)
                ->join('orders', 'gameorderdetails.id_order', '=', 'orders.id')
                ->join('users', 'orders.id_buyer', '=', 'users.id')
                ->selectRaw('DATE(orders.order_date) as date, COUNT(*) as copies_sold, SUM(gameorderdetails.purchase_price) as total_earnings, gameorderdetails.purchase_price, users.name as buyer_name')
                ->when($query, function ($q) use ($query) {
                    return $q->where('users.name', 'ILIKE', "%$query%");
                })
                ->groupBy('date', 'gameorderdetails.purchase_price', 'users.name')
                ->orderBy('date')
                ->paginate(6);

            // Pass data to the seller profile view
            if ($request->ajax()) {
                return view('partials.purchase-history', compact('purchaseHistory'));
            }

            return view('pages.seller', compact('seller', 'sellerGames', 'categories', 'game', 'purchaseHistory'));
        } catch (\Exception $e) {
            Log::error('Error in showing seller profile: ' . $e->getMessage());
            return redirect()->route('seller.home')->with('error', 'An error occurred.');
        }
    }

    public function sellerHome(Request $request)
    {
        try {
            $seller = Auth::user();
            $query = $request->input('query');

            $sellerGames = Game::with(['categories', 'images'])
                ->when($seller->role == 2, function ($q) use ($seller) {
                    return $q->where('id_seller', $seller->id);
                })->when($seller->role == 3, function ($q) {
                    return $q; // Fetch all games if the user is an admin
                })
                ->when($query, function ($q) use ($query) {
                    return $q->where('name', 'ILIKE', "%$query%");
                })
                ->paginate(6);

            $categories = Category::all();

            if ($request->ajax()) {
                return view('partials.games-list', compact('sellerGames'));
            }

            return view('pages.seller-home', compact('seller', 'sellerGames', 'categories'));
        } catch (\Exception $e) {
            Log::error('Error in sellerHome method: ' . $e->getMessage());
            return redirect()->route('home')->with('error', 'An error occurred.');
        }
    }

    public function createPromotion(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'game_id' => 'required|exists:game,id',
                'discount_percentage' => 'required|numeric|min:1|max:100',
            ]);

            $game = Game::findOrFail($validatedData['game_id']);
            $this->authorize('update', $game);

            $discountPercentage = $validatedData['discount_percentage'];
            $discountPrice = $game->price - ($game->price * ($discountPercentage / 100));

            $game->update([
                'is_on_sale' => true,
                'discount_price' => $discountPrice,
            ]);

            return redirect()->route('seller')->with('success', 'Promotion created successfully.');
        } catch (\Exception $e) {
            Log::error('Error creating promotion: ' . $e->getMessage());
            return redirect()->route('seller')->with('error', 'Error creating promotion: ' . $e->getMessage());
        }
    }
}