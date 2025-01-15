<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Image;

class ImageController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $images = Image::all();
        return response()->json($images);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(string $image_path, string $id_game)
    {
        // Create a new image.
        $image = new Image();

        // Check if the current user is authorized to create this Image.
        $this->authorize('create', $image);

        // Set image details.
        $image->path = $image_path;
        $image->id_game = $id_game;
        $image->id_user = Auth::user()->id;

        // Save the image
        $image->save();

        return response()->json($image);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $image = Image::findOrFail($id);
        return response()->json($image);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        $image = Image::findOrFail($id);

        // Check if the current user is authorized to edit this Image.
        $this->authorize('edit', $image);

        return response()->json($image);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $request->validate([
            'path' => 'required|string',
            'id_game' => 'required|integer|exists:games,id',
        ]);

        $image = Image::findOrFail($id);
        $image->path = $request->input('path');
        $image->id_game = $request->input('id_game');
        $image->save();

        return response()->json($image);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $image = Image::findOrFail($id);
        $image->delete();

        return response()->json(null, 204);
    }
    /**
     * Search for images by user ID.
     */
    public function searchByUserId(string $id_user)
    {
        $images = Image::where('id_user', $id_user)->get();
        return response()->json($images);
    }

    /**
     * Handle the image upload and save the image path.
     */
    public function upload(Request $request)
    {
        $request->validate([
            'images.*' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $imagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('img', 'public');
                $imagePaths[] = $path;

                // Save the image path to the database
                $imageModel = new Image();
                $imageModel->path = $path;
                $imageModel->id_user = Auth::user()->id;
                $imageModel->save();
            }
        }

        return response()->json(['image_paths' => $imagePaths], 201);
    }
}