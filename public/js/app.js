document.addEventListener("DOMContentLoaded", function () {
  // ===================== GAME FORM SUBMISSION =====================
  const gameForm = document.getElementById("gameForm");
  if (gameForm) {
    // Fetch existing game names
    let existingGameNames = [];
    fetch("/games/names")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok " + response.statusText);
        }
        return response.json();
      })
      .then((data) => {
        existingGameNames = data;
      })
      .catch((error) => console.error("Error fetching game names:", error));

    gameForm.addEventListener("submit", function (event) {
      // Clear previous error messages
      const errorDiv = document.getElementById("categories-error");
      if (errorDiv) {
        errorDiv.style.display = "none";
        errorDiv.textContent = "";
      }

      // Check if at least one category is selected
      const selectedCategories = gameForm.querySelectorAll(
        'input[name="categories[]"]:checked'
      );
      if (selectedCategories.length === 0) {
        let errorDiv = document.getElementById("categories-error");
        if (!errorDiv) {
          errorDiv = document.createElement("div");
          errorDiv.id = "categories-error";
          errorDiv.classList.add("text-danger");
          gameForm.querySelector("div.row.mb-3").appendChild(errorDiv);
        }
        errorDiv.textContent = "Please select at least one category.";
        errorDiv.style.display = "block";
        event.preventDefault();
      } else {
        // Check if the game name already exists
        const gameName = gameForm
          .querySelector('input[name="name"]')
          .value.trim();
        if (existingGameNames.includes(gameName)) {
          let errorDiv = document.getElementById("name-error");
          if (!errorDiv) {
            errorDiv = document.createElement("div");
            errorDiv.id = "name-error";
            errorDiv.classList.add("text-danger");
            gameForm.querySelector("div.row.mb-3").appendChild(errorDiv);
          }
          errorDiv.textContent = "A game with this name already exists.";
          errorDiv.style.display = "block";
          event.preventDefault();
        } else {
          // Check image size and number
          const images = gameForm.querySelector('input[name="images[]"]').files;
          const maxImages = 5;
          const maxSize = 2 * 1024 * 1024; // 2MB
          let totalSize = 0;
          for (let i = 0; i < images.length; i++) {
            totalSize += images[i].size;
            if (images[i].size > maxSize) {
              alert("Each image must be less than 2MB.");
              event.preventDefault();
              return;
            }
          }
          if (images.length > maxImages) {
            alert("You can upload a maximum of 5 images.");
            event.preventDefault();
            return;
          }
        }
      }
    });
  }

  // ===================== CARD INPUT VALIDATION =====================
  // Cardholder Name
  const cardName = document.getElementById("card-name");
  if (cardName) {
    cardName.addEventListener("input", function () {
      this.value = this.value.replace(/[^a-zA-Z\s]/g, "");
    });
  }

  // Card Number
  const cardNumber = document.getElementById("card-number");
  if (cardNumber) {
    cardNumber.addEventListener("input", function () {
      let sanitizedValue = this.value.replace(/\D/g, "");
      sanitizedValue = sanitizedValue.replace(/(\d{4})(?=\d)/g, "$1 ");
      this.value = sanitizedValue.slice(0, 19);
    });
  }

  // Expiry Date
  const expiryDate = document.getElementById("expiry-date");
  if (expiryDate) {
    expiryDate.addEventListener("input", function () {
      let sanitizedValue = this.value.replace(/\D/g, "");
      if (sanitizedValue.length > 2) {
        sanitizedValue =
          sanitizedValue.slice(0, 2) + "/" + sanitizedValue.slice(2, 4);
      }
      this.value = sanitizedValue.slice(0, 5);
    });
  }

  // CVV
  const cvv = document.getElementById("cvv");
  if (cvv) {
    cvv.addEventListener("input", function () {
      this.value = this.value.replace(/\D/g, "").slice(0, 3);
    });
  }

  // ===================== SHOW MORE BUTTON FUNCTIONALITY =====================
  const showMoreButton = document.getElementById("show-more");
  if (showMoreButton) {
    showMoreButton.addEventListener("click", function () {
      var nextUrl = this.getAttribute("data-next-url");

      fetch(nextUrl)
        .then((response) => response.json())
        .then((data) => {
          if (data.games) {
            document
              .getElementById("game-list")
              .insertAdjacentHTML("beforeend", data.games);

            if (!data.nextPageUrl) {
              this.style.display = "none";
            } else {
              this.setAttribute("data-next-url", data.nextPageUrl);
            }
          }
        })
        .catch((error) => {
          console.error("Error loading more games:", error);
          response.text().then((text) => console.log("Response Text:", text));
        });
    });
  }

  // ===================== EDIT GAME FORM SUBMISSION =====================
  const editGameForm = document.getElementById("editGameForm");
  if (editGameForm) {
    // Fetch existing game names
    let existingGameNames = [];
    fetch("/games/names")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok " + response.statusText);
        }
        return response.json();
      })
      .then((data) => {
        existingGameNames = data;
      })
      .catch((error) => console.error("Error fetching game names:", error));

    editGameForm.addEventListener("submit", function (event) {
      // Clear previous error messages
      const categoriesErrorDiv = document.getElementById("categories-error");
      const imagesErrorDiv = document.getElementById("images-error");
      const nameErrorDiv = document.getElementById("name-error");
      categoriesErrorDiv.style.display = "none";
      categoriesErrorDiv.textContent = "";
      imagesErrorDiv.style.display = "none";
      imagesErrorDiv.textContent = "";
      if (nameErrorDiv) {
        nameErrorDiv.style.display = "none";
        nameErrorDiv.textContent = "";
      }

      // Check if at least one category is selected
      const selectedCategories = editGameForm.querySelectorAll(
        'input[name="categories[]"]:checked'
      );
      if (selectedCategories.length === 0) {
        categoriesErrorDiv.textContent = "Please select at least one category.";
        categoriesErrorDiv.style.display = "block";
        event.preventDefault();
        return;
      }

      // Check if at least one image is present
      const existingImages = editGameForm.querySelectorAll(
        'input[name="remove_images[]"]:checked'
      ).length;
      const newImages = editGameForm.querySelector('input[name="images[]"]')
        .files.length;
      if (
        existingImages ===
          editGameForm.querySelectorAll('input[name="remove_images[]"]')
            .length &&
        newImages === 0
      ) {
        imagesErrorDiv.textContent = "Please upload at least one image.";
        imagesErrorDiv.style.display = "block";
        event.preventDefault();
        return;
      }

      // Check image size and number
      const images = editGameForm.querySelector('input[name="images[]"]').files;
      const maxImages = 5;
      const maxSize = 2 * 1024 * 1024; // 2MB
      let totalSize = 0;
      for (let i = 0; i < images.length; i++) {
        totalSize += images[i].size;
        if (images[i].size > maxSize) {
          imagesErrorDiv.textContent = "Each image must be less than 2MB.";
          imagesErrorDiv.style.display = "block";
          event.preventDefault();
          return;
        }
      }
      if (images.length > maxImages) {
        imagesErrorDiv.textContent = "You can upload a maximum of 5 images.";
        imagesErrorDiv.style.display = "block";
        event.preventDefault();
        return;
      }

      // Check if the game name already exists
      const gameName = editGameForm
        .querySelector('input[name="name"]')
        .value.trim();
      const currentGameName = editGameForm
        .querySelector('input[name="current_name"]')
        .value.trim();
      if (
        gameName !== currentGameName &&
        existingGameNames.includes(gameName)
      ) {
        let errorDiv = document.getElementById("name-error");
        if (!errorDiv) {
          errorDiv = document.createElement("div");
          errorDiv.id = "name-error";
          errorDiv.classList.add("text-danger");
          editGameForm.querySelector("div.row.mb-3").appendChild(errorDiv);
        }
        errorDiv.textContent = "A game with this name already exists.";
        errorDiv.style.display = "block";
        event.preventDefault();
      }
    });
  }

  // ===================== INFINITE SCROLL =====================
  let currentPage = 1;
  let loading = false;
  let hasMoreGames = true;

  const loadMoreGames = () => {
      if (loading || !hasMoreGames) return;

      const gameContainer = document.getElementById('game-container');
      const loadingIndicator = document.getElementById('loading');

      loading = true;
      loadingIndicator.style.display = 'block';

      currentPage++;
      fetch(`?page=${currentPage}`, {
          headers: {
              'X-Requested-With': 'XMLHttpRequest'
          }
      })
      .then(response => response.text())
      .then(data => {
          if (data.trim() === '') {
              hasMoreGames = false;
              window.removeEventListener('scroll', handleScroll);
          } else {
              gameContainer.innerHTML += data;
          }
      })
      .catch(error => console.error('Error loading games:', error))
      .finally(() => {
          loading = false;
          loadingIndicator.style.display = 'none';
      });
  };

  const handleScroll = () => {
      const scrollable = document.documentElement.scrollHeight - window.innerHeight;
      const scrolled = window.scrollY;

      if (scrolled >= scrollable - 200) {
          loadMoreGames();
      }
  };

  window.addEventListener('scroll', handleScroll);

  // ===================== GAME EDIT =====================
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
        const newImages = form.querySelector('input[name="images[]"]').files.length;
        if (existingImages === form.querySelectorAll('input[name="remove_images[]"]').length && newImages === 0) {
            imagesErrorDiv.textContent = "Please upload at least one image.";
            imagesErrorDiv.style.display = "block";
            event.preventDefault();
        }
    });
  });

// ===================== STRIPE PAYMENTS =====================
  document.addEventListener('DOMContentLoaded', () => {
    const cardElement = document.getElementById('card-element');
    if (!cardElement) {
        console.error('The #card-element is not present on the page.');
        return;
    }

    const stripe = Stripe(stripePublicKey);
    const elements = stripe.elements();
    const card = elements.create('card');

    card.mount('#card-element');

    const form = document.querySelector('form[action="' + paymentRoute + '"]');
    form.addEventListener('submit', function (event) {
      event.preventDefault();

      const cardholderName = document.getElementById('card-name').value;
      const email = document.getElementById('email').value;

      stripe.createToken(card, {
          name: cardholderName,
      }).then(function (result) {
          if (result.error) {
              const errorElement = document.getElementById('card-errors');
              errorElement.textContent = result.error.message;
          } else {
              const token = result.token.id;

              const hiddenTokenField = document.createElement('input');
              hiddenTokenField.setAttribute('type', 'hidden');
              hiddenTokenField.setAttribute('name', 'stripeToken');
              hiddenTokenField.setAttribute('value', token);
              form.appendChild(hiddenTokenField);

              const hiddenNameField = document.createElement('input');
              hiddenNameField.setAttribute('type', 'hidden');
              hiddenNameField.setAttribute('name', 'card_name');
              hiddenNameField.setAttribute('value', cardholderName);
              form.appendChild(hiddenNameField);

              const hiddenEmailField = document.createElement('input');
              hiddenEmailField.setAttribute('type', 'hidden');
              hiddenEmailField.setAttribute('name', 'email');
              hiddenEmailField.setAttribute('value', email);
              form.appendChild(hiddenEmailField);

              form.submit();
            }
        });
    });
  });

// ===================== PUSHER NOTIFICATIONS =====================
if (typeof userId !== 'undefined' && typeof pusherAppKey !== 'undefined' && typeof pusherCluster !== 'undefined') {
  const notificationList = document.getElementById('notification-list');

  const pusher = new Pusher(pusherAppKey, {
      cluster: pusherCluster,
  });

  const channel = pusher.subscribe('notifications');

  channel.bind('notification.created', function(data) {
      if (data.notification.id_user === userId) {
          const newNotification = `
              <div class="notification-item unread">
                  <p class="message">${data.notification.message}</p>
                  <small class="date">${data.notification.notification_date}</small>
              </div>
          `;
          notificationList.innerHTML = newNotification + notificationList.innerHTML;
      }
  });
  } else {
    console.error("Required variables for Pusher notifications are not defined.");
  }
});

// ===================== TOGGLE DISCOUNT PRICE FIELD =====================
document.addEventListener('DOMContentLoaded', function () {
  const isOnSaleCheckbox = document.getElementById('is_on_sale');
  const discountPriceRow = document.getElementById('discount-price-row');
  const discountPriceInput = document.getElementById('discount_price');

  function toggleDiscountPrice() {
      if (isOnSaleCheckbox.checked) {
          discountPriceRow.style.display = 'flex';
          discountPriceInput.required = true;
      } else {
          discountPriceRow.style.display = 'none';
          discountPriceInput.required = false;
          discountPriceInput.value = '';
      }
  }

  toggleDiscountPrice();

  isOnSaleCheckbox.addEventListener('change', toggleDiscountPrice);
});

// ===================== GAME SLIDER FUNCTIONALITY =====================
document.addEventListener('DOMContentLoaded', () => {
  document
    .querySelectorAll(".game-slider-container")
    .forEach((sliderContainer) => {
      const slider = sliderContainer.querySelector(".game-slider");
      const leftArrow = sliderContainer.querySelector(".left-arrow");
      const rightArrow = sliderContainer.querySelector(".right-arrow");
      const gameCards = slider.querySelectorAll(".game-card-vertical");
      const totalGames = gameCards.length;
      let currentIndex = 0;

      // Function to determine how many games to show based on screen width
      function getGamesToShow() {
        return window.innerWidth <= 768 ? 1 : 4;
      }

      // Function to move the slider left or right
      function moveSlider(direction) {
        const gamesToShow = getGamesToShow();
        currentIndex += direction;

        // Wrap around logic for the slider
        if (currentIndex < 0) {
          currentIndex = totalGames - gamesToShow;
        } else if (currentIndex > totalGames - gamesToShow) {
          currentIndex = 0;
        }

        const newTransformValue = -(currentIndex * (100 / gamesToShow)) + "%";
        slider.style.transform = `translateX(${newTransformValue})`;
      }

      // Event listeners for the arrows to move the slider
      leftArrow.addEventListener("click", () => moveSlider(-1));
      rightArrow.addEventListener("click", () => moveSlider(1));

      // Reset slider position when window is resized
      window.addEventListener("resize", () => {
        currentIndex = 0;
        slider.style.transform = "translateX(0%)";
      });
    });
});

function prevImage(gameId) {
  const carousel = document.querySelector(`#carousel-${gameId}`);
  const items = carousel.querySelectorAll('.carousel-item');
  let currentIndex = Array.from(items).findIndex(item => item.classList.contains('visible'));

  items[currentIndex].classList.remove('visible');
  currentIndex = (currentIndex - 1 + items.length) % items.length; // Move to the previous image
  items[currentIndex].classList.add('visible');
}

function nextImage(gameId) {
  const carousel = document.querySelector(`#carousel-${gameId}`);
  const items = carousel.querySelectorAll('.carousel-item');
  let currentIndex = Array.from(items).findIndex(item => item.classList.contains('visible'));

  items[currentIndex].classList.remove('visible');
  currentIndex = (currentIndex + 1) % items.length; // Move to the next image
  items[currentIndex].classList.add('visible');
}


