<?php

use App\Models\Category;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;

use App\Http\Controllers\StaticController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\ShoppingCartController;
use App\Http\Controllers\ShoppingCartGameController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\GameOrderDetailsController;

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\ProfileController;

use Illuminate\Http\Request;
use App\Http\Controllers\CustomerSupportController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\SellerController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\OrderController;


/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/


// Home
Route::redirect('/', '/home');


// Homepage 
Route::controller(StaticController::class)->group(function () {
    Route::get('/home', 'index')->name('home');
    Route::get('/about', 'about')->name('about');
    Route::get('/faq', 'faq')->name('faq');
    Route::get('/contact', 'contact')->name('contact');
    Route::get('/seller-home', 'seller')->name('seller.home');
    Route::get('/seller-home/search', [GameController::class, 'searchSellerGames'])->name('seller.searchGames');
});

// Game
Route::controller(GameController::class)->group(function () {
    Route::get('/games/{id}', 'show')->name('games.showinfo');
    Route::get('/home', 'allGames')->name('games');
    Route::get('/highlighted', 'highlightedGames')->name('games.highlighted');
    Route::get('/sales', 'gamesOnSale')->name('games.sales');
    Route::get('/search', 'search')->name('games.search');
    Route::get('/games/{id}/edit', [GameController::class, 'edit'])->name('games.edit');
    Route::put('/games/{id}', [GameController::class, 'update'])->name('games.update');
    Route::get('/games/names', [GameController::class, 'getGameNames'])->name('games.names'); 
    Route::get('/games/{id}/stats', [GameController::class, 'getGameStats'])->name('games.stats');
    Route::get('/games/{id}/purchase-history', [GameController::class, 'getGamePurchaseHistory'])->name('games.purchaseHistory');
    Route::post('/promotions/end', [GameController::class, 'endPromotion'])->name('promotions.end');
    Route::post('/promotions/create', [GameController::class, 'createPromotion'])->name('promotions.create');
    Route::put('/games/{id}/update-stock', [GameController::class, 'updateStock'])->name('games.updateStock');
});

Route::middleware('auth')->group(function () {
    Route::get('/cart', [ShoppingCartController::class, 'index'])->name('cart.show');
    Route::get('/wishlist', [WishlistController::class, 'index'])->name('wishlist.show');
    Route::delete('/cart/remove/{game}', [ShoppingCartController::class, 'removeFromCart'])->name('cart.remove');
    Route::post('/cart/add/{game}', [ShoppingCartController::class, 'addToCart'])->name('cart.add');
    Route::post('/wishlist/add/{game}', [WishlistController::class, 'addToWishlist'])->name('wishlist.add');
    Route::delete('/wishlist/remove/{game}', [WishlistController::class, 'removeFromWishlist'])->name('wishlist.remove');
    Route::post('/checkout', [ShoppingCartController::class, 'buyNow'])->name('buy.now');
    Route::delete('/games/{id}', [GameController::class, 'destroy'])->name('games.destroy');
    Route::get('/add-game', [GameController::class, 'showAddGameForm'])->name('games.add');
    Route::post('/add-game', [GameController::class, 'create'])->name('games.create');
});

Route::get('/checkout', [ShoppingCartController::class, 'checkout'])->name('checkout');
Route::post('/process-payment', [ShoppingCartController::class, 'charge'])->name('processPayment');

Route::post('/place-order', [ShoppingCartController::class, 'placeOrder'])->name('placeOrder');
Route::get('/order-success', function () {
    return view('pages.order-success');
})->name('checkout.success');

// Authentication
Route::controller(LoginController::class)->group(function () {
    Route::get('/login', 'showLoginForm')->name('login');
    Route::post('/login', 'authenticate');
    Route::get('/logout', 'logout')->name('logout');
});

Route::controller(RegisterController::class)->group(function () {
    Route::get('/register', 'showRegistrationForm')->name('register');
    Route::post('/register', 'register');
});

Route::controller(ProfileController::class)->group(function () {
    Route::get('/profile/{id}', 'showProfile')->name('profile');
    Route::put('/profile/{id}', 'updateProfile')->name('profileUpdate');
    Route::post('/profile/{id}/update-picture', 'updatePicture')->name('profile.updatePicture');
    Route::get('/profile/{id}/edit', [ProfileController::class, 'editProfile'])->name('profile.edit');
});
Route::delete('/profile/{id}/delete', [ProfileController::class, 'deleteAccount'])->name('deleteAccount');

Route::get('/categories/{id}', [CategoryController::class, 'show'])->name('categories.show');

// hideNav 
Route::get('/about', function () {
    return view('pages.about')->with('hideNav', true);
})->name('about');

Route::get('/features', function () {
    return view('pages.faq')->with('hideNav', true);
})->name('features');

Route::get('/contact', function () {
    return view('pages.contact')->with('hideNav', true);
})->name('contact');

// Contact Form Submission
Route::post('/contact/submit', [App\Http\Controllers\ContactController::class, 'submit'])->name('contact.submit');


Route::controller(CustomerSupportController::class)->group(function () {
    Route::get('/customer-support', 'index')->name('customer-support.index'); // Página inicial
    Route::post('/customer-support', 'store')->name('customer-support.store'); // Submissão de mensagens
});

Route::get('/admin/customer-support', [CustomerSupportController::class, 'list'])->name('customer-support.list')->middleware('auth', 'admin');

Route::middleware(['auth'])->group(function () {
    Route::get('/seller/support-messages', [CustomerSupportController::class, 'sellerViewMessages'])
        ->name('seller.support.messages');
});

Route::post('/support-messages/{id}/response', [CustomerSupportController::class, 'storeResponse'])
    ->name('support-messages.storeResponse');

Route::middleware(['auth'])->group(function () {
    Route::get('/buyer-support-messages', [CustomerSupportController::class, 'buyerMessages'])->name('buyer.support.messages');
});

Route::get('/support', [CustomerSupportController::class, 'index'])->name('support');

Route::get('/support/conversations', [CustomerSupportController::class, 'listConversations'])->name('support.conversations');

Route::get('/support/conversations/{id}', [CustomerSupportController::class, 'viewConversation'])
    ->name('support.conversations.view');
Route::get('/support/start/{gameId}', [CustomerSupportController::class, 'startSupport'])
    ->name('support.conversation.start');
Route::post('/support/message/add/{id}', [CustomerSupportController::class, 'addMessage'])
    ->name('support.message.addMessage');
Route::post('/support/conversation/{id}/message', [CustomerSupportController::class, 'addMessage'])
    ->name('customer-support.addMessage');

Route::middleware('auth')->group(function () {
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications', [NotificationController::class, 'store']);
    Route::patch('/notifications/{id}/mark-as-read', [NotificationController::class, 'markAsRead'])->name('notifications.mark-as-read');
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy'])->name('notifications.destroy');
    Route::post('/notifications/mark-all-as-read', [NotificationController::class, 'markAllAsRead'])
    ->name('notifications.mark-all-as-read');
});

Route::middleware(['auth', 'admin'])->group(function () {
    Route::get('/admin-console', [AdminController::class, 'showConsole'])->name('admin.console');
    Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser'])->name('admin.deleteUser');
    Route::post('/admin/add-entry', [AdminController::class, 'addEntry'])->name('admin.addEntry');
    Route::post('/admin/delete-entry', [AdminController::class, 'deleteEntry'])->name('admin.deleteEntry');
    Route::get('/get-objects', [AdminController::class, 'getObjects'])->name('admin.getObjects');
});

Route::get('/reviews/add/{id_order}/{id_game}', [GameOrderDetailsController::class, 'addOrEdit'])->name('reviews.add');
Route::get('/reviews/edit/{id_order}/{id_game}', [GameOrderDetailsController::class, 'addOrEdit'])->name('reviews.edit');
Route::post('/reviews/{id_order}/{id_game}', [GameOrderDetailsController::class, 'save'])->name('reviews.save');
Route::delete('/reviews/{id_order}/{id_game}', [GameOrderDetailsController::class, 'delete'])->name('reviews.delete');


Route::get('/games', [GameController::class, 'index'])->name('games.index');

Route::get('/seller/{id}', [SellerController::class, 'show'])->name('seller');
Route::delete('/admin/games/{id}', [AdminController::class, 'deleteGame'])->name('admin.deleteGame');
Route::get('/admin/users/{user}/reviews', [AdminController::class, 'checkReviews'])->name('admin.checkReviews');
Route::patch('/admin/users/{id}/toggle-review-block', [AdminController::class, 'toggleReviewBlock'])->name('admin.toggleReviewBlock');

Route::get('/order-history', [OrderController::class, 'index'])->name('order-history');

Route::get('password/reset', [App\Http\Controllers\Auth\PasswordResetController::class, 'showResetRequestForm'])->name('password.request');
Route::post('password/email', [App\Http\Controllers\Auth\PasswordResetController::class, 'sendResetLinkEmail'])->name('password.email');
Route::get('password/reset/{token}', [App\Http\Controllers\Auth\PasswordResetController::class, 'showResetForm'])->name('password.reset');
Route::post('password/reset', [App\Http\Controllers\Auth\PasswordResetController::class, 'reset'])->name('password.update');

Route::get('/order-history/{id}', [ProfileController::class, 'orderHistory'])->name('order-history');
