<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\shoppingCart;

class Buyer extends Model
{
    protected $table = 'lbaw2496.buyer';

    public $timestamps = false;

    protected $primaryKey = 'id_user';

    public $incrementing = false;

    protected $fillable = ['id_user'];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'id_buyer');
    }

    public function purchasedGames()
    {
        return $this->hasManyThrough(
            Game::class,
            GameOrderDetails::class,
            'id_order',
            'id',
            'id_user',
            'id_game'
        );
    }
}
