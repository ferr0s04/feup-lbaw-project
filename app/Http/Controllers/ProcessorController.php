<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ProcessorController extends Controller
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
        $processor = new Processor();

        // Check if the current user is authorized to create this Processor.
        $this->authorize('create', $processor);

        // Validate the request input
        $validatedData = $request->validate([
            'processor' => 'required|string|unique:pixelmarket.processor,name|max:100',
        ]);

        // Create the Processor
        $processor->processor = $validatedData['processor'];
        $processor->save();

        return response()->json($processor);
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
