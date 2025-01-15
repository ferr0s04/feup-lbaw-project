<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\GameOrderDetails;

class OrderController extends Controller
{
    // Show the user's order history
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $orders = Order::where('id_buyer', $userId)
            ->with(['gameOrderDetails.game'])
            ->orderBy('order_date', 'desc')
            ->get();

        return view('pages.order-history', compact('orders'));
    }
}
