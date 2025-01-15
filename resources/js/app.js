document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("gameForm");
  if (form) {
    form.addEventListener("submit", function (event) {
      // Clear previous error messages
      const errorDiv = document.getElementById("categories-error");
      if (errorDiv) {
        errorDiv.style.display = "none";
        errorDiv.textContent = "";
      }

      // Validate form input
      const selectedCategories = form.querySelectorAll('input[name="categories[]"]:checked');
      if (selectedCategories.length === 0) {
        let errorDiv = document.getElementById("categories-error");
        if (!errorDiv) {
          errorDiv = document.createElement("div");
          errorDiv.id = "categories-error";
          errorDiv.classList.add("text-danger");
          form.querySelector("div.row.mb-3").appendChild(errorDiv);
        }
        errorDiv.textContent = "Please select at least one category.";
        errorDiv.style.display = "block";
        event.preventDefault();
      } else {
        // If validation passes, submit the form using AJAX
        event.preventDefault(); // Prevent normal form submission

        const formData = new FormData(form); // Collect form data

        fetch(form.action, {
          method: 'POST',
          body: formData,
          headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
          }
        })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            // Update the seller's game list if the game is added successfully
            const sellerGamesContainer = document.getElementById("seller-games-container");
            if (sellerGamesContainer && data.html) {
              sellerGamesContainer.innerHTML = data.html;
            }
          } else {
            // Handle validation or other errors
            console.error('Error:', data.errors || data.message);
            alert('Error adding the game. Please try again.');
          }
        })
        .catch(error => {
          console.error('Error:', error);
          alert('Error adding the game. Please try again.');
        });
      }
    });
  }
});
