<?php

namespace App\Policies;

use App\Models\Image;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ImagePolicy
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
    public function view(User $user, Image $image): bool
    {
        //
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        // Only sellers and admins can create a new image.
        return true;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Image $image): bool
    {
        // Everyone can update the image.
        return true;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Image $image): bool
    {
        return $user->id === $image->user_id || $user->is_admin;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Image $image): bool
    {
        //
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Image $image): bool
    {
        //
    }
}
