<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SupportConversation extends Model
{
    use HasFactory;
    protected $table = 'supportconversations';
    public $timestamps = false;
    
    protected $fillable = [
        'id_buyer',
        'id_seller',
        'id_game', 
        'start_date',
    ];

    public function messages()
    {
        return $this->hasMany(SupportMessage::class, 'id_conversation');
    }

    public function buyer()
    {
        return $this->belongsTo(Buyer::class, 'id_buyer');
    }

    public function seller()
    {
        return $this->belongsTo(Seller::class, 'id_seller');
    }

    public function game()
    {
        return $this->belongsTo(Game::class, 'id_game'); 
    }
}
