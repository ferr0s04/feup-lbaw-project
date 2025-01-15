<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $table = 'lbaw2496.payment';

    // Define the fillable attributes
    protected $fillable = [
        'amount',
        'paymentDate',
    ];

    // Define attribute casting
    protected $casts = [
        'amount' => 'decimal:2',  // Assuming Positive is a decimal type
        'paymentDate' => 'datetime',
    ];

    // Disable timestamps
    public $timestamps = false;
}
