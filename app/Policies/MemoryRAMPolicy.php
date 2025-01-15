<?php

namespace App\Policies;

use App\Models\MemoryRAM;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class MemoryRAMPolicy
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
    public function view(User $user, MemoryRAM $memoryRAM): bool
    {
        //
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        // Only sellers and admins can create MemoryRAMs
        return $user->role == 2 || $user->role == 3;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, MemoryRAM $memoryRAM): bool
    {
        //
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, MemoryRAM $memoryRAM): bool
    {
        //
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, MemoryRAM $memoryRAM): bool
    {
        //
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, MemoryRAM $memoryRAM): bool
    {
        //
    }
}
