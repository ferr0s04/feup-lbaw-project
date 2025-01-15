<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HelpSupport extends Model
{
    use HasFactory;
    protected $table = 'helpsupport';
    public $timestamps = false;
    protected $fillable = [
        'message',
        'type',
        'help_date',
        'id_buyer',
    ];
    public function buyer()
    {
        return $this->belongsTo(\App\Models\Buyer::class, 'id_buyer');
    }

    public function responses()
    {
        return $this->hasMany(\App\Models\SupportConversation::class, 'id_support_message', 'id');
    }
}