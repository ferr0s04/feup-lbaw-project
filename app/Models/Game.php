<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Game extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'price',
        'description',
        'stock',
        'rating',
        'release_date',
        'is_highlighted',
        'is_on_sale',
        'id_seller',
        'id_operatingsystem',
        'id_memoryram',
        'id_processor',
        'id_graphicscard',
        'id_storage',
        'discount_price',
    ];
    protected $table = 'lbaw2496.game';

    public $timestamps = false;

    protected $casts = [
        'release_date' => 'datetime',
    ];

    public function seller()
    {
        return $this->belongsTo(Seller::class, 'id_seller', 'id_user');
    }

    public function operatingSystem()
    {
        return $this->belongsTo(OperatingSystem::class, 'id_operatingsystem', 'id');
    }

    public function memoryRAM()
    {
        return $this->belongsTo(MemoryRAM::class, 'id_memoryram', 'id');
    }

    public function processor()
    {
        return $this->belongsTo(Processor::class, 'id_processor', 'id');
    }

    public function graphicsCard()
    {
        return $this->belongsTo(GraphicsCard::class, 'id_graphicscard', 'id');
    }

    public function storage()
    {
        return $this->belongsTo(Storage::class, 'id_storage', 'id');
    }

    public function reviews()
    {
        return $this->hasMany(GameOrderDetails::class, 'id_game', 'id');
    }

    public function shoppingCarts()
    {
        return $this->belongsToMany(ShoppingCart::class, 'shoppingcart_game', 'id_game', 'id_shoppingcart');
    }

    public function images()
    {
        return $this->hasMany(Image::class, 'id_game');
    }

    public function categories()
    {
        return $this->belongsToMany(
            Category::class,
            'game_category', // Pivot table with schema prefix
            'id_game',                   // Foreign key on the pivot table for this model
            'id_category'                // Foreign key on the pivot table for the related model
        );
    }

    public function gameOrderDetails()
    {
        return $this->hasMany(GameOrderDetails::class, 'id_game');
    }
}
