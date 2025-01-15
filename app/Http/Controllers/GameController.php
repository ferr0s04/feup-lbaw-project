<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Game;
use App\Models\Category;
use App\Models\OperatingSystem;
use App\Models\MemoryRAM;
use App\Models\Storage;
use App\Models\Processor;
use App\Models\GraphicsCard;
use App\Models\Wishlist;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Exception;
use Carbon\Carbon;
use App\Models\GameOrderDetails;
use Illuminate\Validation\ValidationException;

class GameController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {

        $query = Game::query()
            ->selectRaw('
                game.*,
                CASE
                    WHEN game.is_on_sale = TRUE AND game.discount_price IS NOT NULL THEN game.discount_price
                    ELSE game.price
                END AS final_price
            ');

        if ($request->has('sort_by') && $request->has('direction')) {
            $sortBy = $request->input('sort_by');
            $direction = $request->input('direction');

            $allowedSorts = ['final_price', 'rating', 'release_date'];
            if (in_array($sortBy, $allowedSorts)) {
                $query->orderByRaw("$sortBy $direction");
            }
        }

        $games = $query->paginate(12);

        return view('pages.games', compact('games'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        try {
            Log::info('Starting game creation process.');

            $game = new Game();

            $this->authorize('create', $game);

            $defaultValues = [
                'is_highlighted' => 0,
                'is_on_sale' => 0,
                'rating' => 0,
                'release_date' => Carbon::now()->toDateString(),
            ];

            // Validate the request input
            $validatedData = $request->validate([
                'name' => 'required|string|unique:game,name|max:255',
                'price' => 'required|numeric|min:0',
                'description' => 'nullable|string',
                'stock' => 'required|integer|min:0',
                'operatingsystem' => 'nullable|string|max:100',
                'memoryram' => 'nullable|integer',
                'processor' => 'nullable|string|max:100',
                'graphicscard' => 'nullable|string|max:100',
                'storage' => 'nullable|integer',
                'categories' => 'required|array|min:1',
                'categories.*' => 'integer',
                'images' => 'required|array|min:1',
                'images.*' => 'file|mimes:jpeg,png,jpg,gif|max:2048',
                'seller' => 'required_if:role,3|exists:users,id',
            ], [
                'categories.required' => 'Please select at least one category.',
                'categories.min' => 'Please select at least one category.',
            ]);

            Log::info('Validation passed.', ['validatedData' => $validatedData]);

            $validatedData = array_merge($validatedData, $defaultValues);


            // Check and create related entities if they don't exist
            $operatingSystem = OperatingSystem::firstOrCreate(['operatingsystem' => $validatedData['operatingsystem']]);
            $memoryRAM = MemoryRAM::firstOrCreate(['memoryram' => $validatedData['memoryram']]);
            $processor = Processor::firstOrCreate(['processor' => $validatedData['processor']]);
            $graphicsCard = GraphicsCard::firstOrCreate(['graphicscard' => $validatedData['graphicscard']]);
            $storage = Storage::firstOrCreate(['storage' => $validatedData['storage']]);

            Log::info('Related entities created or found.');

            $game->fill($validatedData);
            $game->id_seller = Auth::user()->role == 3 ? $validatedData['seller'] : Auth::user()->id;
            $game->id_operatingsystem = $validatedData['operatingsystem'] ?? null;
            $game->id_memoryram = $validatedData['memoryram'] ?? null;
            $game->id_processor = $validatedData['processor'] ?? null;
            $game->id_graphicscard = $validatedData['graphicscard'] ?? null;
            $game->id_storage = $validatedData['storage'] ?? null;

            // Save the game record
            $game->save();
            $game->categories()->sync($validatedData['categories']);

            Log::info('Game saved and categories synced.');

            // Handle image uploads
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $index => $image) {
                    $imageName = uniqid() . "-$index." . $image->getClientOriginalExtension();
                    $image->move(public_path('img'), $imageName);
                    $game->images()->create(['image_path' => "img/$imageName"]);
                }
            }

            Log::info('Images uploaded successfully.');

            return redirect()->route('seller.home')->with('success', 'Game added successfully.');
        } catch (ValidationException $e) {
            Log::error('Validation error during game creation.', ['errors' => $e->errors()]);
            return redirect()->route('games.add')->withErrors($e->errors())->withInput();
        } catch (Exception $e) {
            Log::error('Error during game creation.', ['exception' => $e->getMessage()]);
            return redirect()->route('games.add')->with('error', 'Error creating game: ' . $e->getMessage())->withInput();
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id, Request $request)
    {
        $game = Game::with([
            'seller.user',
            'operatingSystem',
            'memoryRAM',
            'processor',
            'graphicsCard',
            'storage',
            'reviews',
            'images'
        ])->findOrFail($id);

        if (!$game->is_on_sale) {
            $game->discount_price = null;
        }

        // Get sorting options from the request, default to 'date_desc'
        $sortBy = $request->input('sort_by', 'date_desc');

        // Query to fetch reviews based on the selected sorting
        $reviewsQuery = $game->reviews()->whereNotNull('review_date');

        switch ($sortBy) {
            case 'rating_asc':
                $reviewsQuery->orderBy('review_rating', 'asc');
                break;
            case 'rating_desc':
                $reviewsQuery->orderBy('review_rating', 'desc');
                break;
            case 'date_asc':
                $reviewsQuery->orderBy('review_date', 'asc');
                break;
            case 'date_desc':
                $reviewsQuery->orderBy('review_date', 'desc');
                break;
            default:
                // Default sorting (if needed)
                $reviewsQuery->orderBy('review_date', 'desc');
                break;
        }

        $filteredReviews = $reviewsQuery->paginate(10);

        $purchasedGame = null;
        $hasReviewed = null;
        $isReviewBlocked = false; // Default to false for guests or non-authenticated users

        if (auth()->check()) {
            $user = auth()->user();

            // Check if the user has purchased the game
            $purchasedGame = GameOrderDetails::where('id_game', $id)
                ->whereHas('order', function ($query) use ($user) {
                    $query->where('id_buyer', $user->id);
                })
                ->with('order')
                ->get()
                ->sortByDesc(function ($detail) {
                    return $detail->order->order_date;
                })
                ->first();

            // Check if the user has already reviewed the game
            $hasReviewed = GameOrderDetails::where('id_game', $id)
                ->whereHas('order', function ($query) use ($user) {
                    $query->where('id_buyer', $user->id);
                })
                ->whereNotNull('review_date')
                ->exists();

            // Check if the user is blocked from reviewing
            $isReviewBlocked = $user->is_review_blocked;
        }

        return view('pages.game-info', compact('game', 'filteredReviews', 'purchasedGame', 'hasReviewed', 'isReviewBlocked', 'sortBy'));
    }


    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $game = Game::with('categories')->findOrFail($id);
        $categories = Category::all();
        $processors = Processor::all();
        $graphicsCards = GraphicsCard::all();
        $storages = Storage::all();
        $memoryRAMs = MemoryRAM::all();
        $operatingSystems = OperatingSystem::all();
        return view('pages.edit-game', compact('game', 'categories', 'processors', 'graphicsCards', 'storages', 'memoryRAMs', 'operatingSystems'));
    }

    private function removeUnusedRelatedEntities($oldOperatingSystem, $oldMemoryRAM, $oldProcessor, $oldGraphicsCard, $oldStorage)
    {
        if (!Game::where('id_operatingsystem', $oldOperatingSystem)->exists()) {
            OperatingSystem::find($oldOperatingSystem)->delete();
        }
        if (!Game::where('id_memoryram', $oldMemoryRAM)->exists()) {
            MemoryRAM::find($oldMemoryRAM)->delete();
        }
        if (!Game::where('id_processor', $oldProcessor)->exists()) {
            Processor::find($oldProcessor)->delete();
        }
        if (!Game::where('id_graphicscard', $oldGraphicsCard)->exists()) {
            GraphicsCard::find($oldGraphicsCard)->delete();
        }
        if (!Game::where('id_storage', $oldStorage)->exists()) {
            Storage::find($oldStorage)->delete();
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        try {
            $game = Game::findOrFail($id);

            $this->authorize('delete', $game);

            // Delete all images associated with the game
            foreach ($game->images as $image) {
                // Delete the image file from the public directory
                $imagePath = public_path($image->image_path);
                if (file_exists($imagePath)) {
                    unlink($imagePath);
                }
                // Delete the image record from the database
                $image->delete();
            }

            // Delete the game
            $game->delete();

            // remove unused related entities
            $this->removeUnusedRelatedEntities($game->id_operatingsystem, $game->id_memoryram, $game->id_processor, $game->id_graphicscard, $game->id_storage);

            return redirect()->route('seller.home')->with('success', 'Game added successfully.');
        } catch (Exception $e) {
            return redirect()->route('seller.home')->with('success', 'Game added successfully.');
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        try {
            $game = Game::findOrFail($id);

            $this->authorize('update', $game);

            $oldPrice = $game->price;

            // Validate the request input
            $validatedData = $request->validate([
                'name' => 'required|string|max:255|unique:game,name,' . $game->id,
                'price' => 'required|numeric|min:0',
                'is_on_sale' => 'nullable|boolean',
                'discount_price' => 'nullable|numeric|min:0|lt:price',
                'description' => 'nullable|string',
                'stock' => 'required|integer|min:0',
                'operatingsystem' => 'nullable|string|max:100',
                'memoryram' => 'nullable|integer',
                'processor' => 'nullable|string|max:100',
                'graphicscard' => 'nullable|string|max:100',
                'storage' => 'nullable|integer',
                'categories' => 'required|array|min:1',
                'categories.*' => 'integer',
                'images' => $request->hasFile('images') ? 'required|array|min:1' : '',
                'images.*' => $request->hasFile('images') ? 'file|mimes:jpeg,png,jpg,gif|max:2048' : '',
                'remove_images' => 'array',
                'remove_images.*' => 'integer|exists:image,id',
            ], [
                'categories.required' => 'Please select at least one category.',
                'categories.min' => 'Please select at least one category.',
            ]);


            // Ensure at least one category is selected
            if (empty($validatedData['categories'])) {
                return redirect()->back()->withErrors(['categories' => 'Please select at least one category.'])->withInput();
            }

            // Handle old related entities

            // Ensure at least one category is selected
            if (empty($validatedData['categories'])) {
                return redirect()->back()->withErrors(['categories' => 'Please select at least one category.'])->withInput();
            }

            // Handle old related entities
            $oldOperatingSystem = $game->id_operatingsystem;
            $oldMemoryRAM = $game->id_memoryram;
            $oldProcessor = $game->id_processor;
            $oldGraphicsCard = $game->id_graphicscard;
            $oldStorage = $game->id_storage;

            $game->update([
                'name' => $validatedData['name'],
                'price' => $validatedData['price'],
                'is_on_sale' => $request->has('is_on_sale'),
                'discount_price' => $request->has('is_on_sale') ? $validatedData['discount_price'] : null,
            ]);

            $game->id_operatingsystem = $validatedData['operatingsystem'] ?? null;
            $game->id_memoryram = $validatedData['memoryram'] ?? null;
            $game->id_processor = $validatedData['processor'] ?? null;
            $game->id_graphicscard = $validatedData['graphicscard'] ?? null;
            $game->id_storage = $validatedData['storage'] ?? null;
            $game->save();

            // Handle many-to-many relationships
            $game->categories()->sync($validatedData['categories']);

            // Handle image removal
            if ($request->has('remove_images')) {
                foreach ($request->input('remove_images') as $imageId) {
                    $image = $game->images()->find($imageId);
                    if ($image) {
                        // Delete the image file from the public directory
                        $imagePath = public_path($image->image_path);
                        if (file_exists($imagePath)) {
                            unlink($imagePath);
                        }
                        // Delete the image record from the database
                        $image->delete();
                    }
                }
            }

            // Ensure at least one image is present
            if ($game->images()->count() == 0 && !$request->hasFile('images')) {
                return redirect()->back()->withErrors(['images' => 'Please upload at least one image.'])->withInput();
            }

            // Handle one-to-many relationships for new images
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $index => $image) {
                    $imageName = Auth::user()->id . '-image' . ($index + 1) . '.' . $image->getClientOriginalExtension();
                    $image->move(public_path('img'), $imageName);
                    // Create the image record and associate it with the game
                    $game->images()->create([
                        'image_path' => 'img/' . $imageName,
                        'game_id' => $game->id,
                    ]);
                }
            }

            // Remove old related entities if they are no longer associated with any game
            $this->removeUnusedRelatedEntities($oldOperatingSystem, $oldMemoryRAM, $oldProcessor, $oldGraphicsCard, $oldStorage);

            // Notify buyers if the price changed
            if ($oldPrice != $game->price) {
                $buyers = Wishlist::where('id_game', $game->id)->pluck('id_user');
                foreach ($buyers as $buyerId) {
                    $notification = Notification::create([
                        'message' => "The price for the game '{$game->name}' has changed.",
                        'notification_date' => now(),
                        'isread' => false,
                        'price_change_not' => $game->id,
                        'id_user' => $buyerId,
                    ]);
                    event(new NotificationCreated($notification));
                }
            }
            Log::info("Game updated successfully for game ID: $id");

            return redirect()->route('seller.home')->with('success', 'Game updated successfully.');
        } catch (ValidationException $e) {
            Log::error('Error updating game: ' . $e->getMessage());
            return redirect()->back()
                ->withErrors($e->errors())
                ->withInput();
        } catch (Exception $e) {
            Log::error('Error updating game: ' . $e->getMessage());
            return redirect()->back()
                ->with('error', 'Error updating game: ' . $e->getMessage())
                ->withInput();
        }
    }

    public function allGames(Request $request)
    {
        $games = Game::with(['categories', 'images'])->paginate(10);
        $highlightedGames = Game::where('is_highlighted', true)->get();
        $sales = Game::with(['categories', 'images'])->where('is_on_sale', true)->paginate(10);

        if ($request->ajax()) {
            return view('partials.games-list', compact('games'));
        }

        return view('pages.home', compact('games', 'highlightedGames', 'sales'));
    }

    public function highlightedGames()
    {
        $highlightedGames = Game::where('is_highlighted', true)->get();
        return view('partials.highlighted-games-panel', compact('highlightedGames'));
    }

    public function gamesOnSale()
    {
        $sales = Game::with(['categories', 'images'])->where('is_on_sale', true)->get();
        return view('partials.sale-games-panel', compact('sales'));
    }

    public function search(Request $request)
    {
        $query = $request->input('query');

        $games = Game::with(['categories', 'images'])
            ->where('name', 'ILIKE', "%$query%")
            ->orWhere('description', 'ILIKE', "%$query%")
            ->get();

        return view('pages.search-results', compact('games', 'query'));
    }

    public function sellerGames()
    {
        try {
            $sellerId = Auth::id();
            $sellerGames = Game::with(['categories', 'images'])->where('id_seller', $sellerId)->get();
            return view('pages.seller', compact('sellerGames'));
        } catch (\Exception $e) {
            return redirect()->route('home')->with('error', 'An error occurred.');
        }
    }

    public function getGameNames()
    {
        try {
            $games = Game::select('id', 'name')->get();
            return response()->json($games);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to fetch game names'], 500);
        }
    }

    public function showAddGameForm()
    {
        $categories = Category::all();
        $processors = Processor::all();
        $graphicsCards = GraphicsCard::all();
        $storages = Storage::all();
        $memoryRAMs = MemoryRAM::all();
        $operatingSystems = OperatingSystem::all();

        return view('pages.add-game', compact('categories', 'processors', 'graphicsCards', 'storages', 'memoryRAMs', 'operatingSystems'));
    }


    public function getGameStats($id)
    {
        try {
            $game = Game::findOrFail($id);

            // Adjust the query to sum the copies sold per day
            $soldCopies = GameOrderDetails::where('id_game', $id)
                ->join('orders', 'gameorderdetails.id_order', '=', 'orders.id')
                ->selectRaw('DATE(orders.order_date) as date, COUNT(*) as copies_sold, SUM(gameorderdetails.purchase_price) as total_earnings')
                ->groupBy('date')
                ->orderBy('date')
                ->get();

            $totalCopiesSold = $soldCopies->sum('copies_sold');
            $totalEarnings = $soldCopies->sum('total_earnings');

            return response()->json([
                'soldCopies' => $soldCopies,
                'totalCopiesSold' => $totalCopiesSold,
                'totalEarnings' => $totalEarnings
            ]);
        } catch (Exception $e) {
            Log::error('Error fetching game stats: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to fetch game stats'], 500);
        }
    }

    public function getGamePurchaseHistory($id, Request $request)
    {
        try {
            $query = $request->input('query');
            $purchaseHistory = GameOrderDetails::where('id_game', $id)
                ->join('orders', 'gameorderdetails.id_order', '=', 'orders.id')
                ->join('users', 'orders.id_buyer', '=', 'users.id')
                ->selectRaw('DATE(orders.order_date) as date, COUNT(*) as copies_sold, SUM(gameorderdetails.purchase_price) as total_earnings, users.name as buyer_name')
                ->when($query, function ($q) use ($query) {
                    return $q->where('users.name', 'ILIKE', "%$query%");
                })
                ->groupBy('date', 'users.name')
                ->orderBy('date')
                ->get();

            return response()->json([
                'purchaseHistory' => $purchaseHistory
            ]);
        } catch (Exception $e) {
            Log::error('Error fetching purchase history: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to fetch purchase history'], 500);
        }
    }

    public function createPromotion(Request $request)
    {
        try {
            Log::debug('createPromotion method triggered.');

            $validatedData = $request->validate([
                'game_id' => 'required|exists:game,id',
                'discount_percentage' => 'required|numeric|min:5|max:100',
            ]);

            $game = Game::findOrFail($validatedData['game_id']);
            $this->authorize('update', $game);

            $discountPercentage = (float) $validatedData['discount_percentage'];
            $discountPrice = round($game->price - ($game->price * ($discountPercentage / 100)), 2);
            Log::debug("Discount percentage applied: $discountPercentage%, Discount price: $discountPrice");

            if ($discountPrice > $game->price) {
                return redirect()->route('seller', ['id' => $game->id])->with('error', 'Discount price cannot be greater than the actual price.');
            }

            if ($discountPercentage == 100) {
                $discountPrice = 0;
                Log::debug("Discount percentage is 100%, setting discount price to FREE.");
            }

            // Update the game directly
            $game->is_on_sale = true;
            $game->discount_price = $discountPrice;
            $game->save();

            Log::debug('Promotion created successfully for game ID: ' . $game->id);

            return redirect()->route('seller', ['id' => $game->id])->with('success', 'Promotion created successfully.')->with('alert', 'Price changed to ' . ($discountPrice == 0 ? 'FREE' : $discountPrice . ' €'));
        } catch (\Exception $e) {
            Log::error('Error creating promotion: ' . $e->getMessage());
            return redirect()->route('seller', ['id' => $game->id])->with('error', 'Error creating promotion: ' . $e->getMessage());
        }
    }

    public function endPromotion(Request $request)
    {
        try {
            Log::debug('endPromotion method triggered.');

            $validatedData = $request->validate([
                'game_id' => 'required|exists:game,id',
            ]);

            $game = Game::findOrFail($validatedData['game_id']);
            $this->authorize('update', $game);

            // Update the game to end the promotion
            $game->is_on_sale = false;
            $game->discount_price = null;
            $game->save();

            Log::debug('Promotion ended successfully for game ID: ' . $game->id);

            return redirect()->route('seller', ['id' => $game->id])->with('success', 'Promotion ended successfully.');
        } catch (\Exception $e) {
            Log::error('Error ending promotion: ' . $e->getMessage());
            return redirect()->route('seller', ['id' => $game->id])->with('error', 'Error ending promotion: ' . $e->getMessage());
        }
    }

    public function searchPurchaseHistory(Request $request, $id)
    {
        try {
            $query = $request->input('query');
            $soldCopies = GameOrderDetails::where('id_game', $id)
                ->join('orders', 'gameorderdetails.id_order', '=', 'orders.id')
                ->join('users', 'orders.id_buyer', '=', 'users.id')
                ->selectRaw('DATE(orders.order_date) as date, COUNT(*) as copies_sold, SUM(gameorderdetails.purchase_price) as total_earnings, gameorderdetails.purchase_price, users.name as buyer_name')
                ->groupBy('date', 'gameorderdetails.purchase_price', 'users.name')
                ->orderBy('date')
                ->get();

            if ($query) {
                $soldCopies = $soldCopies->filter(function ($purchase) use ($query) {
                    return stripos($purchase->buyer_name, $query) !== false;
                });
            }

            return response()->json([
                'soldCopies' => $soldCopies,
                'totalCopiesSold' => $soldCopies->sum('copies_sold'),
                'totalEarnings' => $soldCopies->sum('total_earnings')
            ]);
        } catch (Exception $e) {
            Log::error('Error searching purchase history: ' . $e->getMessage());
            return response()->json(['error' => 'An error occurred while searching purchase history.'], 500);
        }
    }

    public function updateStock(Request $request, $id)
    {
        try {
            $game = Game::findOrFail($id);

            // Check if the current user is authorized to update this Game.
            $this->authorize('update', $game);

            $validatedData = $request->validate([
                'stock' => 'required|integer|min:1',
            ]);

            $game->stock += $validatedData['stock'];
            $game->save();

            return redirect()->route('seller', ['id' => $game->id])->with('success', 'Stock updated successfully.');
        } catch (Exception $e) {
            Log::error('Error updating stock: ' . $e->getMessage());
            return redirect()->route('seller', ['id' => $game->id])->with('error', 'Error updating stock: ' . $e->getMessage());
        }
    }

    public function searchSellerGames(Request $request)
    {
        $query = $request->input('query');
        $sellerId = Auth::id();
        $seller = Auth::user();

        $sellerGamesQuery = Game::with(['categories', 'images']);

        if ($seller->role == 3) { // Check if the user is an admin
            $sellerGamesQuery->where(function ($q) use ($query) {
                $q->where('name', 'ILIKE', "%$query%")
                    ->orWhere('description', 'ILIKE', "%$query%");
            });
        } else {
            $sellerGamesQuery->where('id_seller', $sellerId)
                ->where(function ($q) use ($query) {
                    $q->where('name', 'ILIKE', "%$query%")
                        ->orWhere('description', 'ILIKE', "%$query%");
                });
        }

        $sellerGames = $sellerGamesQuery->paginate(10);
        $categories = Category::all();

        return view('pages.seller-home', compact('sellerGames', 'seller', 'categories'));
    }
}
