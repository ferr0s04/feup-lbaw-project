@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Admin Console</h1>
    <div class="add-objects">
        <h2>Add Objects</h2>
        <form action="{{ route('admin.addEntry') }}" method="POST">
            @csrf
            <div class="row mb-3">
                <label for="itemType" class="col-sm-2 col-form-label">Select Item Type:</label>
                <div class="col-sm-10">
                    <select id="itemType" name="itemType" class="form-control" required>
                        <option value="" disabled selected>Select an item type</option>
                        <option value="operatingsystem">Operating System</option>
                        <option value="memoryram">Memory RAM</option>
                        <option value="processor">Processor</option>
                        <option value="storage">Storage</option>
                        <option value="graphicscard">Graphics Card</option>
                        <option value="category">Category</option>
                    </select>
                </div>
            </div>
            <div class="row mb-3" id="dynamicInputField">
                <label for="dynamicInput" class="col-sm-2 col-form-label">Enter Value:</label>
                <div class="col-sm-10">
                    <input type="text" id="dynamicInput" name="dynamicInput" class="form-control" placeholder="Enter value" required>
                </div>
            </div>
            <div class="text-center mt-3">
                <button type="submit" class="btn btn-primary">Add Entry</button>
            </div>
        </form>
    </div>

    <h2>Users</h2>
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>
                    <div class="d-flex justify-content-between align-items-center">
                        <span>Actions</span>
                        <!-- Search Bar -->
                        <form action="{{ route('admin.console') }}" method="GET" class="form-inline">
                            <div class="input-group">
                                <input type="text" class="form-control" name="search" value="{{ request()->get('search') }}" placeholder="Search by Name or Email">
                                <select name="role" class="form-control ml-2">
                                    <option value="" disabled {{ request()->get('role') ? '' : 'selected' }}>Select Role</option>
                                    <option value="1" {{ request()->get('role') == '1' ? 'selected' : '' }}>Buyer</option>
                                    <option value="2" {{ request()->get('role') == '2' ? 'selected' : '' }}>Seller</option>
                                </select>
                                <button type="submit" class="btn btn-custom me-2">Search</button>
                            </div>
                        </form>
                    </div>
                </th>
            </tr>
        </thead>
        <tbody>
            @foreach ($users as $user)
                <tr>
                    <td>{{ $user->id }}</td>
                    <td>{{ $user->name }}</td>
                    <td>{{ $user->email }}</td>
                    <td>
                        @if ($user->role === 1)
                            Buyer
                        @elseif ($user->role === 2)
                            Seller
                        @endif
                    </td>
                    <td>
                        <!-- View Profile Button -->
                        <a href="{{ route('profile', $user->id) }}" class="btn btn-custom me-2">View Profile</a>
                        <!-- View Seller Profile Button -->
                        @if ($user->role === 2)
                            <a href="{{ route('seller', $user->id) }}" class="btn btn-custom me-2">View Seller Profile</a>
                        @endif
                        <!-- Check Reviews Button -->
                        @if ($user->role === 1)
                            <a href="{{ route('admin.checkReviews', $user->id) }}" class="btn btn-custom me-2">Check Reviews</a>
                        @endif
                        <!-- Delete User Button -->
                        <form action="{{ route('admin.deleteUser', $user->id) }}" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger">Delete</button>
                        </form>
                    </td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Pagination -->
    <div class="d-flex justify-content-center mt-4">
        @if ($users->lastPage() > 1)
            <ul class="pagination">
                <!-- Previous Page Link -->
                <li class="page-item {{ ($users->currentPage() == 1) ? 'disabled' : '' }}">
                    <a class="page-link" href="{{ $users->previousPageUrl() }}">Previous</a>
                </li>

                <!-- Page Numbers -->
                @php
                    $currentPage = $users->currentPage();
                    $lastPage = $users->lastPage();
                    $rangeStart = max(1, $currentPage - 2); // Start 2 pages before the current page
                    $rangeEnd = min($lastPage, $currentPage + 2); // End 2 pages after the current page
                @endphp

                @for ($i = $rangeStart; $i <= $rangeEnd; $i++)
                    <li class="page-item {{ ($users->currentPage() == $i) ? 'active' : '' }}">
                        <a class="page-link" href="{{ $users->url($i) }}">{{ $i }}</a>
                    </li>
                @endfor

                <!-- Next Page Link -->
                <li class="page-item {{ ($users->currentPage() == $users->lastPage()) ? 'disabled' : '' }}">
                    <a class="page-link" href="{{ $users->nextPageUrl() }}">Next</a>
                </li>
            </ul>
        @endif
    </div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        @if(session('success'))
            alert('Success: {{ session('success') }}');
        @elseif(session('error'))
            alert('Error: {{ session('error') }}');
        @endif
    });
</script>
@endsection
