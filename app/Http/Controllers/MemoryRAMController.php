<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MemoryRAMController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create($request)
    {
        $memoryram = new MemoryRAM();

        // Check if the current user is authorized to create this MemoryRAM.
        $this->authorize('create', $memoryram);

        // Set memoryram details.
        $validatedData = $request->validate([
            'memoryram' => 'required|integer',
        ]);

        // Create a new MemoryRAM
        $memoryram->memoryram = $validatedData['memoryram'];
        $memoryram->save();

        return response()->json($memoryram);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
