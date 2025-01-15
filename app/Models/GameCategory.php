<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GameCategory extends Model
{
    use HasFactory;

    public function game()
    {
        return $this->belongsTo(Game::class, 'id_game', 'id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'id_category', 'id');
    }
}
