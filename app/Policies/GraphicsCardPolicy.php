<?php

namespace App\Policies;

use App\Models\GraphicsCard;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class GraphicsCardPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        //
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, GraphicsCard $graphicsCard): bool
    {
        //
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        // Only sellers and admins can create GraphicsCards
        return $user->role == 2 || $user->role == 3;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, GraphicsCard $graphicsCard): bool
    {
        //
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, GraphicsCard $graphicsCard): bool
    {
        //
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, GraphicsCard $graphicsCard): bool
    {
        //
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, GraphicsCard $graphicsCard): bool
    {
        //
    }
}
