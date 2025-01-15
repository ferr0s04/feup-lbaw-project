<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OperatingSystem extends Model
{
    protected $table = 'lbaw2496.operatingsystem';
    protected $fillable = [
        'operatingsystem',
    ];

    public $timestamps = false;
}
