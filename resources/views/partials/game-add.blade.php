<div class="text-center mb-4">
    <h1 class="display-7">Add Games</h1>
</div>
<div class="card shadow-sm p-4">
    <form id="gameForm" action="{{ route('games.create') }}" method="POST" enctype="multipart/form-data">
        {{ csrf_field() }}
        <div class="row mb-3">
            <label for="name" class="col-sm-2 col-form-label">Name:</label>
            <div class="col-sm-10">
                <input type="text" class="form-control" id="name" name="name" required>
                @error('name')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="row mb-3">
            <label for="price" class="col-sm-2 col-form-label">Price:</label>
            <div class="col-sm-10">
                <input type="number" step="0.01" id="price" name="price" class="form-control" required>
                @error('price')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="row mb-3">
            <label for="is_on_sale" class="col-sm-2 col-form-label">On Sale?</label>
            <div class="col-sm-10">
                <div class="form-check-sale">
                    <input type="checkbox" class="form-check-input" id="is_on_sale" name="is_on_sale" 
                        value="1" {{ old('is_on_sale', isset($game) ? $game->is_on_sale : 0) ? 'checked' : '' }}>
                    <label class="form-check-label" for="is_on_sale"></label>
                </div>
            </div>
        </div>
        <div class="row mb-3" id="discount-price-row" style="display: none;">
            <label for="discount_price" class="col-sm-2 col-form-label">Discount Price:</label>
            <div class="col-sm-10">
                <input type="number" step="0.01" id="discount_price" name="discount_price" class="form-control" 
                    value="{{ old('discount_price', isset($game) ? $game->discount_price : '') }}">
                @error('discount_price')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="row mb-3">
            <label for="description" class="col-sm-2 col-form-label">Description:</label>
            <div class="col-sm-10">
                <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                @error('description')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="row mb-3">
            <label for="stock" class="col-sm-2 col-form-label">Stock:</label>
            <div class="col-sm-10">
                <input type="number" class="form-control" id="stock" name="stock" required>
                @error('stock')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="row mb-3">
            <label for="operatingsystem" class="col-sm-2 col-form-label">Operating System:</label>
            <div class="col-sm-10">
                <select id="operatingsystem" name="operatingsystem" class="form-control">
                    <option value="" disabled {{ old('operatingsystem', $game->operatingsystem ?? '') ? '' : 'selected' }}>Select an operating system</option>
                    @foreach($operatingSystems as $operatingSystem)
                        <option value="{{ $operatingSystem->id }}" {{ old('operatingsystem', $game->id_operatingsystem ?? '') == $operatingSystem->id ? 'selected' : '' }}>
                            {{ $operatingSystem->operatingsystem }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="row mb-3">
            <label for="memoryram" class="col-sm-2 col-form-label">Memory RAM:</label>
            <div class="col-sm-10">
                <select id="memoryram" name="memoryram" class="form-control">
                    <option value="" disabled {{ old('memoryram', $game->memoryram ?? '') ? '' : 'selected' }}>Select a memory RAM</option>
                    @foreach($memoryRAMs as $memoryRAM)
                        <option value="{{ $memoryRAM->id }}" {{ old('memoryram', $game->id_memoryram ?? '') == $memoryRAM->id ? 'selected' : '' }}>
                            {{ $memoryRAM->memoryram }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="row mb-3">
            <label for="processor" class="col-sm-2 col-form-label">Processor:</label>
            <div class="col-sm-10">
                <select id="processor" name="processor" class="form-control">
                    <option value="" disabled {{ old('processor', $game->processor ?? '') ? '' : 'selected' }}>Select a processor</option>
                    @foreach($processors as $processor)
                        <option value="{{ $processor->id }}" {{ old('processor', $game->id_processor ?? '') == $processor->id ? 'selected' : '' }}>
                            {{ $processor->processor }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="row mb-3">
            <label for="graphicscard" class="col-sm-2 col-form-label">Graphics Card:</label>
            <div class="col-sm-10">
                <select id="graphicscard" name="graphicscard" class="form-control">
                    <option value="" disabled {{ old('graphicscard', $game->graphicscard ?? '') ? '' : 'selected' }}>Select a graphics card</option>
                    @foreach($graphicsCards as $graphicsCard)
                        <option value="{{ $graphicsCard->id }}" {{ old('graphicscard', $game->id_graphicscard ?? '') == $graphicsCard->id ? 'selected' : '' }}>
                            {{ $graphicsCard->graphicscard }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        <div class="row mb-3">
            <label for="storage" class="col-sm-2 col-form-label">Storage:</label>
            <div class="col-sm-10">
                <select id="storage" name="storage" class="form-control">
                    <option value="" disabled {{ old('storage', $game->storage ?? '') ? '' : 'selected' }}>Select a storage</option>
                    @foreach($storages as $storage)
                        <option value="{{ $storage->id }}" {{ old('storage', $game->id_storage ?? '') == $storage->id ? 'selected' : '' }}>
                            {{ $storage->storage }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
        @if(Auth::user()->role == 3)
        <div class="row mb-3">
            <label for="seller" class="col-sm-2 col-form-label">Seller:</label>
            <div class="col-sm-10">
                <select id="seller" name="seller" class="form-control" required>
                    <option value="" disabled selected>Select a seller</option>
                    @foreach($sellers as $seller)
                        <option value="{{ $seller->id }}">{{ $seller->name }}</option>
                    @endforeach
                </select>
                @error('seller')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        @endif
        <div class="row mb-3">
            <label for="categories" class="col-sm-2 col-form-label">Categories:</label>
            <div class="col-sm-10">
                <div id="categories" class="row">
                    @foreach ($categories as $category)
                        <div class="col-lg-4 col-md-6 col-sm-12 mb-2">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="categories[]"
                                    id="category_{{ $category->id }}" value="{{ $category->id }}"
                                    @if(in_array($category->id, old('categories', []))) checked @endif>
                                <label class="form-check-label" for="category_{{ $category->id }}">
                                    {{ $category->category_name }}
                                </label>
                            </div>
                        </div>
                    @endforeach
                </div>
                <!-- Error message for categories -->
                <div id="categories-error" class="text-danger" style="display: none;"></div>
            </div>
        </div>
        <div class="row mb-3">
            <label for="images" class="col-sm-2 col-form-label">Upload Images:</label>
            <div class="col-sm-10">
                <input type="file" id="images" name="images[]" class="form-control" multiple required>
                @error('images')
                    <div class="text-danger">{{ $message }}</div>
                @enderror
            </div>
        </div>
        <div class="text-end">
            <button type="submit" class="btn btn-primary">Add Game</button>
        </div>
    </form>
</div>