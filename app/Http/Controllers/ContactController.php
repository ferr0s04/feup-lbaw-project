<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\ContactMail;

class ContactController extends Controller
{
    public function submit(Request $request)
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
        ]);
    
        Mail::to('info@pixelmarket.com')->send(new ContactMail(
            $validatedData['name'], 
            $validatedData['email'], 
            $validatedData['subject'], 
            $validatedData['message']
        ));
    
        return redirect()->back()->with('success', 'Your message has been sent successfully!');
    }
}