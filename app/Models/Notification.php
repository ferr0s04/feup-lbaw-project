<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $table = 'lbaw2496.notification';

    public $timestamps = false;

    protected $fillable = [
        'isread',
        'notification_date',
        'id_order',
        'id_game',
        'customer_support_not',
        'price_change_not',
        'product_availability_not',
        'id_user',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}
