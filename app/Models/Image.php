<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Image extends Model
{
    use HasFactory;

    protected $table = 'lbaw2496.image';

    protected $fillable = [
        'image_path',
        'id_game',
        'id_user',
    ];

    public function game()
    {
        return $this->belongsTo(Game::class, 'id_game');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
    public $timestamps = false; // Disable automatic timestamps

}
