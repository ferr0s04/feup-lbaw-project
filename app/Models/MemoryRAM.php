<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MemoryRAM extends Model
{
    protected $table = 'lbaw2496.memoryram';

    // Define the fillable attributes
    protected $fillable = [
        'memoryram',
    ];

    // Disable timestamps
    public $timestamps = false;
}
