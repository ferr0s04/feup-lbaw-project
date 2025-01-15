<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Processor extends Model
{
    protected $table = 'lbaw2496.processor';

    // Define the fillable attributes
    protected $fillable = [
        'processor',
    ];

    // Disable timestamps
    public $timestamps = false;
}
