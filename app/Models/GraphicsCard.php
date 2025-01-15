<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GraphicsCard extends Model
{
    protected $table = 'lbaw2496.graphicscard';

    // Define the fillable attributes
    protected $fillable = [
        'graphicscard',
    ];

    // Disable timestamps
    public $timestamps = false;
}
