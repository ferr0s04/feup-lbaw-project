<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class StorageController extends Controller
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
        $storage = new Storage();

        // Check if the current user is authorized to create this Storage.
        $this->authorize('create', $storage);

        // Set storage details.
        $validatedData = $request->validate([
            'storage' => 'required|integer',
        ]);

        // Create a new Storage
        $storage->storage = $validatedData['storage'];
        $storage->save();

        return response()->json($storage);
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
