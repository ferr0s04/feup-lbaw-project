<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Wishlist extends Model
{
    protected $table = 'lbaw2496.wishlist';
    public $timestamps = false;
    public $incrementing = false;

    protected $fillable = ['id_buyer', 'id_game'];

    public function game()
    {
        return $this->belongsTo(Game::class, 'id_game');
    }

    public function buyer()
    {
        return $this->belongsTo(Buyer::class, 'id_buyer');
    }

    public static function deleteCK($idBuyer, $idGame)
    {
        return static::where('id_buyer', $idBuyer)
                    ->where('id_game', $idGame)
                    ->delete();
    }
}
