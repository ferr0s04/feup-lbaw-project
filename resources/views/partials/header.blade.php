<header class="main-header">
    <div class="logo">
        <a href="{{ url('/home') }}">
            <img  alt="logo" src="/img/logo.png">
        </a>
    </div>
    <form class="search-form d-flex w-100" action="{{ url('/search') }}" method="GET" style="">
        <div class="search-text d-flex w-100">
            <input class="d-flex w-100" type="text" name="query" placeholder="Search">
            <div class="categories-dropdown">
            <button type="button" class="categories-button">All Categories <i class="fa-solid fa-angle-down"></i></button>
            <div class="categories-list">
                @foreach ($categories as $category)
                    <a href="/categories/{{$category->id}}" class="category-item" data-category="{{ $category->id }}">
                        {{ $category->category_name }}
                    </a>
                @endforeach
            </div>
        </div>
        </div>
        <button type="submit"><i class="fa-solid fa-magnifying-glass"></i></button>
    </form>

    <nav class="nav-links">
        @if (Auth::check() && Auth::user()->role == '1')
            <a href="{{ url('/wishlist') }}" class="wishlist-button">
                <i class="far fa-xl fa-heart"></i>
            </a>
            <a href="{{ url('/cart') }}" class="shopping-cart-button">
                <i class="fa-solid fa-xl fa-cart-shopping"></i>
            </a>
        @endif
        @if (Auth::check())
            @if (Auth::user()->role == '2')
                <a class="button" href="{{ url('/seller-home') }}">Seller Profile</a>
            @elseif (Auth::user()->role == '3')
                <a class="button" href="{{ url('/seller-home') }}">Games Panel</a>
            @endif
            <a href="{{ route('profile', ['id' => Auth::user()->id]) }}" class="account-icon-container" style="position: relative;">
                <i class="fa-solid fa-xl fa-user"></i>

                <!-- Unread notifications indicator (yellow circle) -->
                @if(Auth::user()->unreadNotifications->count() > 0)
                    <span class="unread-indicator"></span>
                @endif
            </a>
            <a class="button" href="{{ url('/logout') }}">Logout</a>
        @else
            <a class="button" href="{{ url('/login') }}">Login</a>
        @endif
    </nav>
</header>

<script>
    document.querySelector('.categories-button').addEventListener('click', function (e) {
    const dropdown = document.querySelector('.categories-list');
    dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    e.stopPropagation();
});

document.addEventListener('click', function () {
    const dropdown = document.querySelector('.categories-list');
    dropdown.style.display = 'none';
});

document.querySelectorAll('.category-item').forEach(item => {
    item.addEventListener('click', function () {
        const selectedCategory = this.textContent;
        document.querySelector('.categories-button').textContent = selectedCategory;
        document.querySelector('input[name="category_id"]').value = this.getAttribute('data-category');
    });
});

</script>