@extends('layouts.app')

@section('content')
<div class="container d-flex justify-content-center align-items-center min-vh-100">
    <div class="profile-container py-5 w-100" style="max-width: 600px;">

        <!-- Profile Header -->
        <div class="profile-header d-flex align-items-center">
            <div class="profile-picture me-4">
                <img id="profilePicturePreview" 
                    src="{{ $user->profile_picture ? asset('storage/' . $user->profile_picture) : asset('img/noprofileimage.png') }}" 
                    alt="{{ $user->name }}" 
                    class="rounded-circle border"
                    style="width: 150px; height: 150px; object-fit: cover;">
            </div>
            <div>
                <h1 class="mb-0">{{ $user->username }}</h1>
                <p class="text-muted" id="bioPreview">{{ $user->bio ?? 'No bio available.' }}</p>
            </div>
        </div>

        <!-- Delete Account Button (Top Right) -->
        <div class="text-end mb-3">
            <form method="POST" action="{{ route('deleteAccount', $user->id) }}" id="deleteAccountForm" class="d-inline">
                @csrf
                @method('DELETE')
                <button type="submit" class="btn btn-danger">Delete Account</button>
            </form>
        </div>

        <!-- Profile Form -->
        <form method="POST" action="{{ route('profileUpdate', $user->id) }}" enctype="multipart/form-data" id="profileForm" data-user-id="{{ $user->id }}">
            @csrf
            @method('PUT')

            <!-- Username -->
            <div class="mb-3">
                <label for="username">Username:</label>
                <input type="text" name="username" id="username" value="{{ $user->username }}" class="form-control" required>
            </div>

            <!-- Bio -->
            <div class="mb-3">
                <label for="bio">Bio:</label>
                <textarea name="bio" id="bio" rows="3" class="form-control">{{ $user->bio }}</textarea>
            </div>

            <!-- Profile Picture -->
            <div class="mb-3">
                <label for="profile_picture">Profile Picture:</label>
                <input type="file" name="profile_picture" id="profile_picture" class="form-control">
            </div>

            <!-- Action Buttons -->
            <div class="mt-3">
                <button type="submit" id="saveButton" class="btn btn-custom me-2">Save Changes</button>
                <button type="button" id="cancelButton" class="btn btn-secondary me-2">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
// Profile editing 
document.addEventListener('DOMContentLoaded', function () {
  const cancelButton = document.getElementById('cancelButton');
  const saveButton = document.getElementById('saveButton');
  const formFields = document.querySelectorAll('#profileForm input, #profileForm textarea');
  const originalValues = {}; // Store original values to reset on cancel

  // Store initial values for cancel action
  formFields.forEach(field => {
      originalValues[field.id] = field.value;
  });

  // Cancel editing and redirect back to profile
  cancelButton.addEventListener('click', function () {
      console.log('Cancel clicked');  // Check if the cancel button is clicked  
      const userId = document.getElementById('profileForm').dataset.userId; // Add a data attribute for user ID
      window.location.href = `/profile/${userId}`;
  });

  // Confirmation prompt before saving
  saveButton.addEventListener('click', function (event) {
      if (!confirm('Are you sure you want to save changes?')) {
          event.preventDefault();
      }
  });
});

document.addEventListener('DOMContentLoaded', function () {
    const deleteAccountForm = document.getElementById('deleteAccountForm');

    deleteAccountForm.addEventListener('submit', function (event) {
        if (!confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
            event.preventDefault();
        }
    });
});
</script>
@endsection
