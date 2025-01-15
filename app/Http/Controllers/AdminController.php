<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use App\Models\Notification;
use App\Models\Game;
use App\Models\Storage;
use App\Models\Processor;
use App\Models\MemoryRAM;
use App\Models\GraphicsCard;
use App\Models\OperatingSystem;
use App\Models\Category;
use App\Models\GameOrderDetails;

class AdminController extends Controller
{
    // Display the admin console
    public function showConsole(Request $request)
    {
        $query = User::where('role', '!=', 3); // Fetch all non-admin users

        // Check if there is a search query for 'name' or 'role'
        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                ->orWhere('email', 'like', '%' . $search . '%');
            });
        }

        if ($request->has('role')) {
            $role = $request->input('role');
            $query->where('role', $role);
        }

        // Paginate the results
        $users = $query->paginate(20);

        return view('pages.admin-console', compact('users'));
    }

    // Delete a non-admin user
    public function deleteUser($id)
    {
        $user = User::findOrFail($id);

        // Ensure admins cannot delete other admins
        if ($user->role === 3) {
            return redirect()->back()->withErrors(['error' => 'You cannot delete another admin.']);
        }

        Notification::where('id_user', $user->id)->update(['id_user' => null]);
        $user->delete();

        return redirect()->route('admin.console')->withSuccess('User deleted successfully.');
    }

    public function deleteGame($id)
    {
        $game = Game::findOrFail($id);

        $game->delete();

        return redirect()->back()->withSuccess('Game deleted successfully.');
    }

    public function checkReviews($userId)
    {
        $user = User::findOrFail($userId);

        // Ensure the user is a buyer
        if ($user->role !== 1) {
            return redirect()->route('admin.console')->with('error', 'This user is not a buyer.');
        }

        // Fetch the reviews made by the user
        $reviews = GameOrderDetails::with('game')
            ->whereHas('order', function ($query) use ($userId) {
                $query->where('id_buyer', $userId);
            })
            ->whereNotNull('review_date') // Only fetch entries with reviews
            ->get();

        return view('partials.admin-check-reviews', compact('user', 'reviews'));
    }

    public function addEntry(Request $request)
    {
        $validatedData = $request->validate([
            'itemType' => 'required|string|in:operatingsystem,memoryram,processor,storage,graphicscard,category',
            'dynamicInput' => 'required|string|max:255',
        ]);

        try {
            switch ($validatedData['itemType']) {
                case 'operatingsystem':
                    OperatingSystem::create(['operatingsystem' => $validatedData['dynamicInput']]);
                    break;
                case 'memoryram':
                    MemoryRAM::create(['memoryram' => $validatedData['dynamicInput']]);
                    break;
                case 'processor':
                    Processor::create(['processor' => $validatedData['dynamicInput']]);
                    break;
                case 'storage':
                    Storage::create(['storage' => $validatedData['dynamicInput']]);
                    break;
                case 'graphicscard':
                    GraphicsCard::create(['graphicscard' => $validatedData['dynamicInput']]);
                    break;
                case 'category':
                    Category::create(['category_name' => $validatedData['dynamicInput']]);
                    break;
                default:
                    throw new Exception('Invalid item type');
            }

            return redirect()->route('admin.console')->with('success', 'Entry added successfully');
        } catch (\Exception $e) {
            return redirect()->route('admin.console')->with('error', 'Error adding entry: ' . $e->getMessage());
        }
    }   
    public function toggleReviewBlock($userId)
    {
        $user = User::findOrFail($userId);

        // Toggle the review block status
        $user->is_review_blocked = !$user->is_review_blocked;
        $user->save();

        if ($user->is_review_blocked) {
            // Remove all reviews made by the user
            GameOrderDetails::whereHas('order', function ($query) use ($userId) {
                $query->where('id_buyer', $userId);
            })->update([
                'review_comment' => null,
                'review_rating' => null,
                'review_date' => null
            ]);
        }

        return redirect()->back()->with(
            'success',
            $user->is_review_blocked 
                ? 'User reviews have been removed, and they are now blocked from reviewing.' 
                : 'User can now leave reviews.'
        );
    }
}
