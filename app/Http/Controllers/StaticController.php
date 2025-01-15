<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Game;
use App\Models\Category;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class StaticController extends Controller
{
  /**
   * Show the application home page.
   *
   */
  public function index()
  {
    return view('pages.home');
  }

  /**
   * Show the application about page.
   *
   */
  public function about()
  {
    return view('pages.about');
  }

  /**
   * Show the application faq page.
   *
   */
  public function faq()
  {
    return view('pages.faq');
  }

  /**
   * Show the application contact page.
   *
   */
  public function contact()
  {
    return view('pages.contact');
  }

  /**
   * Show the application seller page.
   *
   */
  public function seller()
  {
    try {
      $sellerId = Auth::id();
      Log::debug('Seller ID:', ['sellerId' => $sellerId]);

      if (!$sellerId) {
        Log::error('No authenticated user found.');
        return redirect()->route('home')->with('error', 'No authenticated user found.');
      }

      $seller = Auth::user();
      $sellerGames = Game::with(['categories', 'images'])->where('id_seller', $sellerId)->get();
      if(Auth::user()->role == 3) {
        $sellerGames = Game::with(['categories', 'images'])->get();
      }
      $categories = Category::all();

      Log::debug('Seller Games:', ['sellerGames' => $sellerGames]);
      Log::debug('All Categories:', ['categories' => $categories]);

      return view('pages.seller-home', compact('seller', 'sellerGames', 'categories'));
    } catch (\Exception $e) {
      Log::error('Error in seller method: ' . $e->getMessage());
      return redirect()->route('home')->with('error', 'An error occurred.');
    }
  }

}
