<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Buyer;


class Seller extends Model
{
    // Specify the table name if not following Laravel's plural convention
    protected $table = 'lbaw2496.seller';

    // Disable timestamps if they aren't used in this table
    public $timestamps = false;

    // Set the primary key
    protected $primaryKey = 'id_user';

    // Disable auto-incrementing since id_user is a foreign key
    public $incrementing = false;

    // Define the fillable attributes
    protected $fillable = [
        'id_user',
        'rating',
        'total_sales_number',
        'totalEarned',
    ];

    // Define attribute casting
    protected $casts = [
        'rating' => 'decimal:2',  // Assuming RatingRange is stored as an decimal
        'total_sales_number' => 'integer',  // Assuming Positive maps to an integer
        'totalEarned' => 'decimal:2',  // Assuming Positive maps to a decimal (currency) with 2 decimal places
    ];

    // Define the relationship with the User model
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user', 'id');
    }

    public function games()
    {
        return $this->hasMany(Game::class, 'id_seller', 'id_user');
    }

    public function incrementSales(int $amount = 1)
    {
        $this->increment('total_sales_number', $amount);
    }

    public function addToTotalEarned(float $amount)
    {
        $this->increment('totalEarned', $amount);
    }

    public function updateRating(int $newRating, int $totalReviews)
    {
        // Calculate the new average rating
        $currentTotalRating = $this->rating * ($totalReviews - 1); // Current total rating
        $newAverageRating = ($currentTotalRating + $newRating) / $totalReviews;

        // Update the rating
        $this->update(['rating' => round($newAverageRating, 2)]); // Round to 2 decimals
    }
}
