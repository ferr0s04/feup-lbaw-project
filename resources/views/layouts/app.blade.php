<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Styles -->
    <link href="{{ url('css/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{ url('css/app.css') }}" rel="stylesheet">
    <link href="{{ url('css/auth.css') }}" rel="stylesheet">
    <link href="{{ url('css/cart.css') }}" rel="stylesheet">
    <link href="{{ url('css/footer.css') }}" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <script>
        // Fix for Firefox autofocus CSS bug
        // See: http://stackoverflow.com/questions/18943276/html-5-autofocus-messes-up-css-loading/18945951#18945951
    </script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns"></script>
    <script>
        const userId = @json(auth()->id());
        const stripePublicKey = "{{ env('STRIPE_KEY') }}";
        const processPaymentRoute = "{{ route('processPayment') }}";
        const pusherAppKey = "{{ env('PUSHER_APP_KEY') }}";
        const pusherCluster = "{{ env('PUSHER_APP_CLUSTER') }}";
    </script>
    <script src="https://js.stripe.com/v3/"></script>
    <script src="https://js.pusher.com/7.2/pusher.min.js"></script>
    <script src={{ url('js/app.js') }} defer>
    </script>
</head>

<body>
    <main>
        <!-- Top Header -->
        @include('partials.header')

        <!-- Navigation and Search Bar -->
        @if(!isset($hideNav) || !$hideNav)
            <div class="nav-bar-background">
                <div class="nav-bar">
                    <div class="container">
                        <nav class="category-links">
                            <a href="{{ url('/highlighted') }}">Highlighted Games</a>
                            <a href="{{ url('/sales') }}">Sales</a>
                            <a href="{{ route('games.index') }}">Games</a>
                            @auth
                                {{-- Show "Customer Support" and "My Support Messages" for buyers --}}
                                @if(auth()->user()->role === 1) 
                                    <a href="{{ route('buyer.support.messages') }}">Support</a>
                                @endif

                                {{-- Show "Support Messages" for sellers --}}
                                @if (\App\Models\Seller::where('id_user', auth()->id())->exists())
                                    <a href="{{ route('seller.support.messages') }}">Messages</a>
                                @endif

                                {{-- Show console for admins --}}
                                @if(auth()->user()->role === 3)
                                    <a href="{{ route('admin.console') }}">Console</a>
                                @endif
                            @endauth
                        </nav>
                    </div>
                </div>
            </div>
        @endif

        <!-- Main Content -->
        <section id="content">
            @yield('content')
        </section>

        <section id="game-info">
            @yield('game-info')
        </section>

        <section id="shopping-cart">
            @yield('shopping-cart')
        </section>

        <section id="checkout">
            @yield('checkout')
        </section>

        <section id="order-success">
            @yield('order-success')
        </section>
    </main>
    @include('partials.footer')
</body>

</html>