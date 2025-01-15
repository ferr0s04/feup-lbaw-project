<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $table = 'lbaw2496.category';

    protected $fillable = ['category_name'];

    public $timestamps = false;

    public function games()
    {
        return $this->belongsToMany(Game::class, 'game_category', 'id_category', 'id_game');
    }
}

