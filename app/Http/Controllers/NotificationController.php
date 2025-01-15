<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Models\Game;
use App\Models\Order;
use App\Models\User;
use App\Mail\MailModel;
use Illuminate\Support\Facades\Mail;
use App\Events\NotificationCreated;

class NotificationController extends Controller
{
    // Fetch all notifications for a user
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $notifications = Notification::where('id_user', $userId)
            ->orderBy('notification_date', 'desc')
            ->get()
            ->map(function ($notification) {
                $notification->message = $this->generateNotificationMessage($notification);
                return $notification;
            });
    
        return view('pages.notifications', compact('notifications'));
    }

    // Mark a notification as read
    public function markAsRead($id)
    {
        $notification = Notification::findOrFail($id);
        $notification->isread = true;
        $notification->save();

        return redirect()->back();
    }

    // Create a new notification using templates
    public function store(Request $request)
    {
        $data = $request->validate([
            'isread' => 'required|boolean',
            'id_user' => 'nullable|integer',
            'id_order' => 'nullable|integer',
            'id_game' => 'nullable|integer',
            'customer_support_not' => 'nullable|integer',
            'price_change_not' => 'nullable|integer',
            'product_availability_not' => 'nullable|integer',
        ]);
    
        $notification = Notification::create($data);
    
        // Generate the notification message
        $messageContent = $this->generateNotificationMessage($notification);
    
        // Ensure the user exists and has an email
        if ($notification->id_user) {
            $user = User::find($notification->id_user);
            if ($user && $user->email) {
                // Send the email
                Mail::to($user->email)->send(new MailModel($messageContent));
            } else {
            }
        }
    
        event(new NotificationCreated($notification));
    
        return response()->json($notification, 201);
    }

    // Generate notification messages and send email
    private function generateNotificationMessage(Notification $notification)
    {
        $messageContent = '';

        if ($notification->price_change_not) {
            $game = Game::find($notification->price_change_not);
            $messageContent = "The price for game " . $game->name . " has changed.";
        } elseif ($notification->product_availability_not) {
            $game = Game::find($notification->product_availability_not);
            $messageContent = "Game " . $game->name . " is now available.";
        } elseif ($notification->customer_support_not) {
            $messageContent = "Response to your customer support inquiry is available.";
        } elseif ($notification->id_order && $notification->id_game) {
            $order = Order::find($notification->id_order);
            $buyer = User::find($order->id_buyer);
            $game = Game::find($notification->id_game);
            $messageContent = "You sold " . $game->name . " to " . $buyer->name . ".";
        }

        // Send the email with the generated message content
        if ($notification->id_user) {
            $user = User::find($notification->id_user);
            if ($user && $user->email) {
                if (!($notification->id_order && $notification->id_game)) {
                    Mail::to($user->email)->send(new MailModel($messageContent));
                }
            } else {
            }
        }

        return $messageContent;
    }
    
    // Delete a notification
    public function destroy($id)
    {
        $notification = Notification::findOrFail($id);
        $notification->delete();

        return redirect()->back();
    }

    // Mark all notifications as read
    public function markAllAsRead(Request $request)
    {
        $userId = $request->user()->id;

        Notification::where('id_user', $userId)
            ->where('isread', false)
            ->update(['isread' => true]);

        return redirect()->back();
    }
}
