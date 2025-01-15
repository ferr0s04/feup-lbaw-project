<?php

namespace App\Mail;

use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ContactMail extends Mailable
{
    use SerializesModels;

    public $name;
    public $email;
    public $subject;
    public $messageContent;

    // Constructor to set the message details
    public function __construct($name, $email, $subject, $messageContent)
    {
        $this->name = $name;
        $this->email = $email;
        $this->subject = $subject;
        $this->messageContent = $messageContent;
    }

    // Build the message
    public function build()
    {
        return $this->from($this->email, $this->name)
                    ->to('info@pixelmarket.com')
                    ->subject($this->subject)
                    ->view('emails.contact')
                    ->with([
                        'messageContent' => $this->messageContent,
                    ]);
    }
}
