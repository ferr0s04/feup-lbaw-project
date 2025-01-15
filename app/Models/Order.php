<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $table = 'lbaw2496.orders';

    protected $fillable = [
        'total_price', 
        'id_payment',
        'id_buyer',
        'order_date'
    ];

    protected $casts = [
        'order_date' => 'datetime',
    ];

    public $timestamps = false;

    public function gameOrderDetails()
    {
        return $this->hasMany(GameOrderDetails::class, 'id_order');
    }

    public function buyer()
    {
        return $this->belongsTo(Buyer::class, 'id_buyer');
    }
}
