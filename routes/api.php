<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\CardController;
use App\Http\Controllers\ItemController;
use App\Http\Controllers\GameController;


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// // API routes for CardController
// Route::controller(CardController::class)->group(function () {
//     Route::put('/cards', 'create');
//     Route::delete('/cards/{card_id}', 'delete');
// });

// // API routes for ItemController
// Route::controller(ItemController::class)->group(function () {
//     Route::put('/cards/{card_id}', 'create');
//     Route::post('/item/{id}', 'update');
//     Route::delete('/item/{id}', 'delete');
// });

// // API routes for GameController
// Route::controller(GameController::class)->group(function () {
//     Route::get('/games', 'allGames');
//     Route::post('/games', 'create');
// });


// // API routes for ShoppingCartController
// Route::middleware('auth')->group(function () {
//     Route::get('/cart', [ShoppingCartController::class, 'index'])->name('cart.show');
//     Route::delete('/cart/remove/{game}', [ShoppingCartGameController::class, 'removeFromCart'])->name('cart.remove');
//     Route::post('/cart/add/{game}', [ShoppingCartGameController::class, 'addToCart'])->name('cart.add');
//     Route::post('/checkout', [ShoppingCartGameController::class, 'buyNow'])->name('buy.now');
// });

// Route::post('/place-order', [ShoppingCartController::class, 'placeOrder'])->name('placeOrder');