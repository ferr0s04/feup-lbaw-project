<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Storage extends Model
{
    protected $table = 'lbaw2496.storage';

    // Define the fillable attributes
    protected $fillable = [
        'storage',
    ];

    // Disable timestamps
    public $timestamps = false;
}
