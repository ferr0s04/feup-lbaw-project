<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\GameOrderDetails;

class GameOrderDetailsController extends Controller
{
    public function addOrEdit($id_order, $id_game)
    {
        $userId = auth()->user()->id;
    
        $orderDetail = GameOrderDetails::with('order', 'game')
            ->where('id_order', $id_order)
            ->where('id_game', $id_game)
            ->firstOrFail();
    
        $hasReviewed = $orderDetail->review_date !== null;
    
        return view('pages.review', compact('orderDetail', 'hasReviewed'));
    }    

    public function save(Request $request, $id_order, $id_game)
    {
        $user = auth()->user();

        if ($user->is_review_blocked) {
            return redirect()->back()->with('error', 'You are blocked from making reviews.');
        }

        $request->validate([
            'review_rating' => 'required|integer|min:1|max:5',
            'review_comment' => 'nullable|string|max:500',
        ]);

        $gameReview = GameOrderDetails::find([$id_order, $id_game]);
        GameOrderDetails::where('id_order', $id_order)
        ->where('id_game', $id_game)
        ->update([
            'review_rating' => $request->review_rating,
            'review_comment' => $request->review_comment ?? null,
            'review_date' => now(),
        ]);

        return redirect()->route('games.showinfo', $gameReview->id_game);
    }

    public function delete($id_order, $id_game)
    {
        $review = GameOrderDetails::find([$id_order, $id_game]);

        if ($review) {
            GameOrderDetails::where('id_order', $id_order)
            ->where('id_game', $id_game)
            ->update([
                'review_rating' => null,
                'review_comment' => null,
                'review_date' => null,
            ]);
        }

        return redirect()->back();
    }
}
