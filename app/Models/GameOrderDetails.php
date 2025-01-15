<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GameOrderDetails extends Model
{
    use HasFactory;

    // Define the table name if it's not the default pluralized name
    protected $table = 'lbaw2496.gameorderdetails';

    // Define the primary key as a composite key (no auto-increment)
    public $incrementing = false;
    public $timestamps = false;

    // Specify the attributes that are mass assignable
    protected $fillable = [
        'id_order',
        'id_game',
        'review_rating',
        'review_comment',
        'review_date',
        'purchase_price'
    ];

    // Specify the casts for certain attributes
    protected $casts = [
        'review_rating' => 'float',
        'review_date' => 'datetime',
        'purchase_price' => 'float',
    ];

    // Define relationships
    public function game()
    {
    return $this->belongsTo(Game::class, 'id_game');
    }

    public function order()
    {
        return $this->belongsTo(Order::class, 'id_order');
    }

    public static function find($id)
    {
        if (is_array($id) && count($id) === 2) {
            return static::where('id_order', $id[0])
                ->where('id_game', $id[1])
                ->first();
        }

        return parent::find($id);
    }
}
