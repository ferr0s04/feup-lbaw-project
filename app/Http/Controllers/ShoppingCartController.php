<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ShoppingCart;
use App\Models\Game;
use Illuminate\Support\Facades\Auth;
use App\Models\Buyer;
use App\Models\Payment;
use App\Models\Order;
use App\Models\Seller;
use App\Models\GameOrderDetails;

use Stripe\Stripe;
use Stripe\Customer;
use Stripe\Charge;
use Stripe\Invoice;

class ShoppingCartController extends Controller
{
    // Display the shopping cart
    public function index()
    {
        if (!auth()->check()) {
            return redirect()->route('login');
        }
    
        $user = auth()->user();
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->back()->with('error', 'No buyer found.');
        }
    
        // Fetch purchased games
        $purchasedGames = [];

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
    
        $shoppingCart = ShoppingCart::with('game')->where('id_buyer', auth()->id())->get();
    
        // Delete games from the shopping cart that the user has already purchased
        foreach ($shoppingCart as $item) {
            if (array_key_exists($item->game->id, $purchasedGames)) {
                ShoppingCart::deleteCK($buyer->id_user, $item->game->id);
            }
        }
    
        // Re-fetch the updated shopping cart after removal
        $shoppingCart = ShoppingCart::with('game')->where('id_buyer', auth()->id())->get();
    
        if ($shoppingCart->isEmpty()) {
            return view('pages.shopping-cart', ['shoppingCart' => null, 'totalPrice' => 0]);
        }
    
        $totalPrice = $shoppingCart->sum(function ($item) {
            return $item->game->discount_price ?? $item->game->price;
        });
    
        return view('pages.shopping-cart', [
            'shoppingCart' => $shoppingCart,
            'totalPrice' => $totalPrice,
        ]);
    }
    
    public function checkout()
    {
        $user = auth()->user();
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->route('cart.show')->with('error', 'No buyer found.');
        }

        $shoppingCart = ShoppingCart::with('game')->where('id_buyer', auth()->id())->get();
    
        return view('pages.checkout', compact('shoppingCart'));
    }    

    // Logic to handle for a confirmed order
    public function placeOrder(Request $request)
    {
        $user = auth()->user();
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->route('cart.show')->with('error', 'No buyer found.');
        }
    
        $shoppingCart = ShoppingCart::with('game')->where('id_buyer', auth()->id())->get();
    
        $totalPrice = $shoppingCart->sum(function ($item) {
            return $item->game->discount_price ?? $item->game->price;
        });
    
        $payment = new Payment();
        $payment->amount = $totalPrice;
        $payment->payment_date = now();
        $payment->save();
    
        $order = new Order();
        $order->total_price = $totalPrice;
        $order->id_payment = $payment->id;
        $order->id_buyer = $buyer->id_user;
        $order->order_date = now();
        $order->save();
    
        foreach ($shoppingCart as $item) {
            $game = $item->game;
    
            if ($game->stock > 0) {
                $game->stock -= 1;
                $game->save();
            }
    
            $seller = Seller::where('id_user', $game->id_seller)->first();
            if ($seller) {
                $seller->total_sales_number += 1;
                $seller->total_earned += $game->discount_price ?? $game->price;
                $seller->save();
            }

            $orderDetail = new GameOrderDetails();
            $orderDetail->id_order = $order->id;
            $orderDetail->id_game = $game->id;
            $orderDetail->purchase_price = $game->discount_price ?? $game->price;
            $orderDetail->save();


        }
    
        ShoppingCart::where('id_buyer', $buyer->id_user)->delete();
    
        return redirect('/order-success');
    }
    
    // Adds a game to the shopping cart
    public function addToCart(Request $request, $game_id)
    {
        if (!auth()->check()) {
            return redirect()->route('login')->with('error', 'You need to be logged in to add a game to the cart.');
        }
    
        $user = auth()->user();
    
        if ($user->role == '2') {
            return redirect()->back()->with('error', 'Sellers cannot add items to the cart.');
        }
    
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->back()->with('error', 'Buyer not found.');
        }
    
        $game = Game::find($game_id);
    
        if (!$game) {
            return redirect()->back()->with('error', 'Game not found.');
        }
    
        $existingGame = ShoppingCart::where('id_game', $game->id)
            ->where('id_buyer', $buyer->id_user)
            ->first();
    
        if (!$existingGame) {
            ShoppingCart::insert([
                'id_game' => $game->id,
                'id_buyer' => $buyer->id_user,
            ]);
        }
    
        return redirect()->route('cart.show');
    }

    // Immediate checkout for a game
    public function buyNow(Request $request)
    {
        if (!auth()->check()) {
            return redirect()->route('login')->with('error', 'You need to be logged in to make a purchase.');
        }
    
        $user = auth()->user();
    
        if ($user->role == '2') {
            return redirect()->back()->with('error', 'Sellers cannot make purchases.');
        }
    
        $gameId = $request->input('game_id');
        $game = Game::find($gameId);
    
        if (!$game) {
            return redirect()->back()->with('error', 'Game not found.');
        }
    
        $buyer = Buyer::where('id_user', $user->id)->first();
    
        if (!$buyer) {
            return redirect()->back()->with('error', 'Buyer not found.');
        }
    
        $existingGame = ShoppingCart::where('id_game', $game->id)
            ->where('id_buyer', $buyer->id_user)
            ->first();
    
        if (!$existingGame) {
            ShoppingCart::insert([
                'id_game' => $game->id,
                'id_buyer' => $buyer->id_user,
            ]);
        }
    
        return redirect()->route('checkout');
    }

    public function removeFromCart(Request $request, $game_id)
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
    
        ShoppingCart::deleteCK($buyer->id_user, $game->id);
    
        return redirect()->route('cart.show')->with('success', 'Game removed from cart successfully!');
    }

    // Processes a purchase with Stripe
    public function charge(Request $request)
    {
        \Stripe\Stripe::setApiKey(env('STRIPE_SECRET'));
    
        $user = auth()->user();
    
        $shoppingCart = ShoppingCart::with('game')->where('id_buyer', $user->id)->get();
    
        $totalPrice = $shoppingCart->sum(function ($item) {
            return $item->game->discount_price ?? $item->game->price;
        });
    
        try {
            $email = $request->input('email');
            $cardName = $request->input('card_name');
            $stripeToken = $request->stripeToken;
    
            if (!$email || !$cardName || !$stripeToken) {
                return back()->withErrors(['error' => 'Missing required payment information.']);
            }
    
            $customer = \Stripe\Customer::create([
                'email' => $user->email,
                'name' => $user->name,
            ]);
    
            $paymentIntent = \Stripe\PaymentIntent::create([
                'amount' => $totalPrice * 100,
                'currency' => 'eur',
                'customer' => $customer->id,
                'payment_method_data' => [
                    'type' => 'card',
                    'card' => [
                        'token' => $stripeToken,
                    ],
                ],
                'confirmation_method' => 'manual',
                'confirm' => true,
                'return_url' => route('checkout.success'),
            ]);
    
            if ($paymentIntent->status === 'succeeded') {
                foreach ($shoppingCart as $item) {
                    $game = $item->game;
                    $gamePrice = ($game->discount_price ?? $game->price) * 100;
    
                    \Stripe\InvoiceItem::create([
                        'customer' => $customer->id,
                        'amount' => $gamePrice,
                        'currency' => 'eur',
                        'description' => $game->name,
                    ]);
                }

                $invoice = \Stripe\Invoice::create([
                    'customer' => $customer->id,
                    'auto_advance' => true,
                ]);
    
                $finalizedInvoice = $invoice->finalizeInvoice();
                $invoice = \Stripe\Invoice::retrieve($finalizedInvoice->id);

                $payment = new Payment();
                $payment->amount = $totalPrice;
                $payment->payment_date = now();
                $payment->save();
    
                $order = new Order();
                $order->total_price = $totalPrice;
                $order->id_payment = $payment->id;
                $order->id_buyer = $user->id;
                $order->order_date = now();
                $order->save();
    
                foreach ($shoppingCart as $item) {
                    $gamePrice = $item->game->discount_price ?? $item->game->price;
    
                    $gameOrderDetail = new GameOrderDetails();
                    $gameOrderDetail->id_order = $order->id;
                    $gameOrderDetail->id_game = $item->game->id;
                    $gameOrderDetail->purchase_price = $gamePrice;
                    $gameOrderDetail->review_rating = null;
                    $gameOrderDetail->review_comment = null;
                    $gameOrderDetail->review_date = null;
                    $gameOrderDetail->save();
                }
    
                return redirect()->route('checkout.success')->with('success', 'Payment successful and invoice created!');
            } else {
                return back()->withErrors(['error' => 'Payment failed: ' . $paymentIntent->status]);
            }
    
        } catch (\Stripe\Exception\CardException $e) {
            return back()->withErrors(['error' => $e->getMessage()]);
        } catch (\Stripe\Exception\ApiErrorException $e) {
            return back()->withErrors(['error' => 'Stripe API error: ' . $e->getMessage()]);
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Something went wrong. Please try again.']);
        }
    }   
}
