@extends('layouts.app')

@section('content')
<div class="text-center mb-4">
    <h1 class="display-7">Edit Game</h1>
</div>

<div class="card shadow-sm p-4">
    <form id="editGameForm" action="{{ route('games.update', $game->id) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT') <!-- This method is required for updates in Laravel -->

        <!-- Name -->
        <div class="row mb-3">
            <label for="name" class="col-sm-2 col-form-label">Name:</label>
            <div class="col-sm-10">
                <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $game->name) }}"
                    required>
                <input type="hidden" id="current_name" name="current_name" value="{{ $game->name }}">
                @error('name')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>

        <!-- Price -->
        <div class="row mb-3">
            <label for="price" class="col-sm-2 col-form-label">Price:</label>
            <div class="col-sm-10">
                <input type="number" step="0.01" id="price" name="price" class="form-control"
                    value="{{ old('price', $game->price) }}" required>
                @error('price')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>

         <!-- On Sale -->
         <div class="row mb-3">
            <label for="is_on_sale" class="col-sm-2 col-form-label">On Sale?</label>
            <div class="col-sm-10">
                <div class="form-check-sale">
                    <input type="checkbox" class="form-check-input" id="is_on_sale" name="is_on_sale" 
                        value="1" {{ old('is_on_sale', $game->is_on_sale) ? 'checked' : '' }}>
                    <label class="form-check-label" for="is_on_sale"></label>
                </div>
            </div>
        </div>

        <!-- Discount Price -->
        <div class="row mb-3" id="discount-price-row" style="display: none;">
            <label for="discount_price" class="col-sm-2 col-form-label">Discount Price:</label>
            <div class="col-sm-10">
                <input type="number" step="0.01" id="discount_price" name="discount_price" class="form-control" 
                    value="{{ old('discount_price', $game->discount_price) }}">
                @error('discount_price')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>

        <!-- Description -->
        <div class="row mb-3">
            <label for="description" class="col-sm-2 col-form-label">Description:</label>
            <div class="col-sm-10">
                <textarea class="form-control" id="description" name="description"
                    rows="3">{{ old('description', $game->description) }}</textarea>
                @error('description')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>

        <!-- Stock -->
        <div class="row mb-3">
            <label for="stock" class="col-sm-2 col-form-label">Stock:</label>
            <div class="col-sm-10">
                <input type="number" class="form-control" id="stock" name="stock"
                    value="{{ old('stock', $game->stock) }}" required>
                @error('stock')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>

        <!-- Operating System -->
        <div class="row mb-3">
            <label for="operatingsystem" class="col-sm-2 col-form-label">Operating System:</label>
            <div class="col-sm-10">
                <select id="operatingsystem" name="operatingsystem" class="form-control">
                    <option value="" disabled selected>Select operating system</option>
                    @foreach($operatingSystems as $operatingSystem)
                        <option value="{{ $operatingSystem->id }}" {{ old('operatingsystem', $game->id_operatingsystem ?? '') == $operatingSystem->id ? 'selected' : '' }}>
                            {{ $operatingSystem->operatingsystem }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Memory RAM -->
        <div class="row mb-3">
            <label for="memoryram" class="col-sm-2 col-form-label">Memory RAM:</label>
            <div class="col-sm-10">
                <select id="memoryram" name="memoryram" class="form-control">
                    <option value="" disabled selected>Select memory RAM</option>
                    @foreach($memoryRAMs as $memoryRAM)
                        <option value="{{ $memoryRAM->id }}" {{ old('memoryram', $game->id_memoryram ?? '') == $memoryRAM->id ? 'selected' : '' }}>
                            {{ $memoryRAM->memoryram }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Processor -->
        <div class="row mb-3">
            <label for="processor" class="col-sm-2 col-form-label">Processor:</label>
            <div class="col-sm-10">
                <select id="processor" name="processor" class="form-control">
                    <option value="" disabled selected>Select a processor</option>
                    @foreach($processors as $processor)
                        <option value="{{ $processor->id }}" {{ old('processor', $game->id_processor ?? '') == $processor->id ? 'selected' : '' }}>
                            {{ $processor->processor }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Graphics Card -->
        <div class="row mb-3">
            <label for="graphicscard" class="col-sm-2 col-form-label">Graphics Card:</label>
            <div class="col-sm-10">
                <select id="graphicscard" name="graphicscard" class="form-control">
                    <option value="" disabled selected>Select a graphics card</option>
                    @foreach($graphicsCards as $graphicsCard)
                        <option value="{{ $graphicsCard->id }}" {{ old('graphicscard', $game->id_graphicscard ?? '') == $graphicsCard->id ? 'selected' : '' }}>
                            {{ $graphicsCard->graphicscard }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>

        <!-- Storage -->
        <div class="row mb-3">
            <label for="storage" class="col-sm-2 col-form-label">Storage:</label>
            <div class="col-sm-10">
                <select id="storage" name="storage" class="form-control">
                    <option value="" disabled selected>Select storage</option>
                    @foreach($storages as $storage)
                        <option value="{{ $storage->id }}" {{ old('storage', $game->id_storage ?? '') == $storage->id ? 'selected' : '' }}>
                            {{ $storage->storage }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>

            <!-- Categories -->
            <div class="row mb-3">
                <label for="categories" class="col-sm-2 col-form-label">Categories:</label>
                <div class="col-sm-10">
                    <div id="categories" class="row">
                        @foreach ($categories as $category)
                            <div class="col-lg-4 col-md-6 col-sm-12 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="categories[]"
                                        id="category_{{ $category->id }}" value="{{ $category->id }}"
                                        @if(in_array($category->id, old('categories', $game->categories->pluck('id')->toArray()))) checked @endif>
                                    <label class="form-check-label" for="category_{{ $category->id }}">
                                        {{ $category->category_name }}
                                    </label>
                                </div>
                            </div>
                        @endforeach
                    </div>
                    @error('categories')
                        <div class="text-danger">{{ $message }}</div>
                    @enderror
                    <div id="categories-error" class="text-danger" style="display: none;"></div>
                </div>
            </div>

            <!-- Existing Images -->
            <div class="row mb-3">
                <label for="existing-images" class="col-sm-2 col-form-label">Existing Images:</label>
                <div class="col-sm-10">
                    <div class="row">
                        @foreach ($game->images as $image)
                            <div class="col-md-3 mb-2">
                                <img src="{{ asset($image->image_path) }}" class="img-thumbnail w-100 h-auto">
                                <div class="form-check mt-2">
                                    <input class="form-check-input" type="checkbox" name="remove_images[]"
                                        value="{{ $image->id }}" id="remove_image_{{ $image->id }}">
                                    <label class="form-check-label" for="remove_image_{{ $image->id }}">Remove</label>
                                </div>
                            </div>
                        @endforeach
                    </div>
                    <div id="images-error" class="text-danger" style="display: none;"></div>
                </div>
            </div>

            <!-- Upload New Images -->
            <div class="row mb-3">
                <label for="images" class="col-sm-2 col-form-label">Upload New Images:</label>
                <div class="col-sm-10">
                    <input type="file" id="images" name="images[]" class="form-control" multiple>
                    @error('images')
                        <div class="text-danger">{{ $message }}</div>
                    @enderror
                </div>
            </div>

            <!-- Submit Button -->
            <div class="text-end">
                <button type="submit" class="btn btn-primary">Update Game</button>
            </div>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const form = document.getElementById("editGameForm");
        form.addEventListener("submit", function (event) {
            // Clear previous error messages
            const categoriesErrorDiv = document.getElementById("categories-error");
            const imagesErrorDiv = document.getElementById("images-error");
            categoriesErrorDiv.style.display = "none";
            categoriesErrorDiv.textContent = "";
            imagesErrorDiv.style.display = "none";
            imagesErrorDiv.textContent = "";

            // Check if at least one category is selected
            const selectedCategories = form.querySelectorAll('input[name="categories[]"]:checked');
            if (selectedCategories.length === 0) {
                categoriesErrorDiv.textContent = "Please select at least one category.";
                categoriesErrorDiv.style.display = "block";
                event.preventDefault();
                return;
            }

            // Check if at least one image is present
            const existingImages = form.querySelectorAll('input[name="remove_images[]"]:checked').length;
            const totalExistingImages = form.querySelectorAll('input[name="remove_images[]"]').length;
            const newImages = form.querySelector('input[name="images[]"]').files.length;
            if (existingImages === totalExistingImages && totalExistingImages > 0 && newImages === 0) {
                imagesErrorDiv.textContent = "Please upload at least one image.";
                imagesErrorDiv.style.display = "block";
                event.preventDefault();
                return;
            }
        });
    });
</script>
@endsection