<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SupportMessage extends Model
{
    use HasFactory;
    protected $table = 'supportmessages';


    protected $fillable = [
        'id_conversation',
        'sender_role',
        'response_message',
        'response_date',
    ];

    public $timestamps = false;

    public function conversation()
    {
        return $this->belongsTo(SupportConversation::class, 'id_conversation');
    }
}
