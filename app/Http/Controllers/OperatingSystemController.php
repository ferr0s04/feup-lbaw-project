<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class OperatingSystemController extends Controller
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
        $operatingsystem = new OperatingSystem();

        // Check if the current user is authorized to create this OperatingSystem.
        $this->authorize('create', $operatingsystem);   

        // Set operatingsystem details.
        $validatedData = $request->validate([
            'operatingsystem' => 'required|string',
        ]);

        // Create a new OperatingSystem
        $operatingsystem->operatingsystem = $validatedData['operatingsystem'];
        $operatingsystem->save();

        return response()->json($operatingsystem);
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
