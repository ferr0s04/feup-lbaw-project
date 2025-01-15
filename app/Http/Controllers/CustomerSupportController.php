<?php

namespace App\Http\Controllers;

use App\Models\HelpSupport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\SupportResponse;
use App\Models\Seller;
use App\Models\Buyer;
use App\Models\SupportConversation;
use App\Models\SupportMessage;
use App\Models\Game;

class CustomerSupportController extends Controller
{

    public function index()
    {
        return view('pages.customer-support');
    }


    public function store(Request $request)
    {
        $buyer = \App\Models\Buyer::where('id_user', Auth::id())->first();
    
        if (!$buyer) {
            return redirect()->back()->withErrors('Only buyers can submit support requests.');
        }
    
        $request->validate([
            'message' => 'required|string|max:1000',
            'type' => 'required|in:CS,GS',
            'game_id' => 'required|integer|exists:game,id', 
        ]);
    
        $game = \App\Models\Game::findOrFail($request->input('game_id'));
        $seller = $game->seller;
    
        $conversation = \App\Models\SupportConversation::firstOrCreate(
            [
                'id_buyer' => $buyer->id_user,
                'id_seller' => $seller->id_user,
                'id_game' => $game->id,
            ],
            ['start_date' => now()]
        );
    
        \App\Models\SupportMessage::create([
            'id_conversation' => $conversation->id,
            'sender_role' => 'buyer',
            'response_message' => $request->input('message'),
        ]);
    
        return redirect()->route('buyer-support-messages')->with('success', 'Your message has been sent.');
    }
    
    public function list()
    {
        $messages = HelpSupport::with('buyer')->get(); 
        return view('pages.customer-support-list', compact('messages'));
    }

    public function sellerViewMessages()
    {
        $seller = Seller::where('id_user', auth()->id())->first();
    
        if (!$seller) {
            return redirect()->back()->withErrors('Only sellers can view support messages.');
        }
    
        $conversations = SupportConversation::with(['messages', 'buyer.user', 'game'])
            ->where('id_seller', $seller->id_user)
            ->get();
    
        return view('pages.seller-support-messages', compact('conversations'));
    }
    
    public function addResponse(Request $request, $id)
    {
        $request->validate([
            'response_message' => 'required|string|max:1000',
        ]);

        $supportMessage = HelpSupport::findOrFail($id);

        if (!auth()->user()->seller) {
            return redirect()->back()->withErrors('Only sellers can respond to support messages.');
        }

        SupportResponse::create([
            'response_message' => $request->input('response_message'),
            'id_support_message' => $id,
            'id_seller' => auth()->id(),
        ]);

        return redirect()->back()->with('success', 'Response added successfully.');
    }

    public function showSellerMessages()
    {
        $messages = HelpSupport::with('responses.seller.user')
            ->whereHas('responses', function ($query) {
                $query->where('id_seller', auth()->id());
            })->get();

        return view('pages.seller-support-messages', compact('messages'));
    }

    public function storeResponse(Request $request, $id)
    {
        $request->validate([
            'response_message' => 'required|string|max:1000',
        ]);

        $supportMessage = HelpSupport::findOrFail($id);

        if (!auth()->user()->seller) {
            return redirect()->back()->withErrors('Only sellers can respond to support messages.');
        }

        $response = new SupportResponse([
            'response_message' => $request->input('response_message'),
            'response_date' => now(),
            'id_support_message' => $supportMessage->id,
            'id_seller' => auth()->id(),
        ]);

        $response->save();

        return redirect()->back()->with('success', 'Response sent successfully.');
    }

    public function buyerMessages()
    {
        $buyer = \App\Models\Buyer::where('id_user', auth()->id())->first();
    
        if (!$buyer) {
            return redirect()->back()->withErrors('Only buyers can view support messages.');
        }
    
        $conversations = SupportConversation::with(['seller.user', 'messages', 'game'])
            ->where('id_buyer', $buyer->id_user)
            ->orderBy('start_date', 'desc')
            ->get();
    
        return view('pages.buyer-support-messages', compact('conversations'));
    }
    
    public function startConversation(Request $request)
    {
        $buyer = \App\Models\Buyer::where('id_user', Auth::id())->first();
        if (!$buyer) {
            return redirect()->back()->withErrors('Only buyers can start a support conversation.');
        }

        $request->validate([
            'id_seller' => 'required|exists:sellers,id_user',
            'message' => 'required|string|max:1000',
        ]);

        $conversation = SupportConversation::create([
            'id_buyer' => $buyer->id_user,
            'id_seller' => $request->input('id_seller'),
        ]);

        SupportMessage::create([
            'id_conversation' => $conversation->id,
            'sender_role' => 'buyer',
            'response_message' => $request->input('message'),
            'response_date' => now(),
        ]);

        return redirect()->route('customer-support.index')->with('success', 'Conversation started successfully.');
    }

    public function listConversations()
    {
        $user = Auth::user();
    
        if ($user->role == 1) { // Buyer
            $conversations = SupportConversation::where('id_buyer', $user->id)->with('messages')->get();
        } elseif ($user->role == 2) { // Seller
            $conversations = SupportConversation::where('id_seller', $user->id)->with('messages')->get();
        } else {
            return redirect()->back()->withErrors('Only buyers or sellers can view conversations.');
        }
    
        return view('pages.support-conversations', compact('conversations'));
    }

    public function viewConversation($id)
    {
        $conversation = SupportConversation::with(['messages', 'seller.user', 'buyer.user'])
            ->findOrFail($id);

        return view('pages.view-support-conversation', compact('conversation'));
    }

    public function addMessage(Request $request, $id)
    {

        $request->validate([
            'response_message' => 'required|string|max:1000',
        ]);
    
        $conversation = SupportConversation::findOrFail($id);
    
        $senderRole = auth()->user()->role == 1 ? 'buyer' : 'seller';
    
        SupportMessage::create([
            'id_conversation' => $conversation->id,
            'sender_role' => $senderRole,
            'response_message' => $request->input('response_message'),
            'response_date' => now(),
        ]);
    
        return redirect()->back()->with('success', 'Message sent successfully.');
    }
    
    public function startSupport($gameId)
    {
        $buyer = Buyer::where('id_user', Auth::id())->first();
    
        if (!$buyer) {
            return redirect()->back()->withErrors('Only buyers can access support.');
        }
    
        $game = Game::findOrFail($gameId);
        $seller = $game->seller;
    
        $conversation = SupportConversation::firstOrCreate(
            [
                'id_buyer' => $buyer->id_user,
                'id_seller' => $seller->id_user,
                'id_game' => $game->id, 
            ],
            [
                'start_date' => now()
            ]
        );
    
        return redirect()->route('support.conversations.view', ['id' => $conversation->id])
            ->with('success', 'Message sent successfully.');
    }
}
