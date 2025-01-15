<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Game; 

class GamePolicy
{
    /**
     * Create a new policy instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Determine if a given game can be shown to a user.
     */
    public function show(User $user, Game $game): bool
    {
        //
    }

    /**
     * Determine if a game can be created by a user.
     */
    public function create(User $user): bool
    {
        // Only sellers and admins can create a new game.
        return $user->role == '2' || $user->role == '3';
    }

    /**
     * Determine if a game can be deleted by a user.
     */
    public function delete(User $user, Game $game): bool
    {
        // Only a seller or an admin can delete it.
        return $user->role == '2' || $user->role == '3';
    }

    /**
     * Determine if a game can be updated by a user.
     */
    public function update(User $user, Game $game): bool
    {
        // Only a seller or an admin can update it.
        return $user->role == '2' || $user->role == '3';
    }
}
