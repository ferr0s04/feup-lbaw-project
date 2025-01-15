@extends('layouts.app')

@section('title', 'Seller')

@section('content')
@if(Auth::user()->role == 3 || Auth::user()->role == 2)
    <div class="container mt-5">
        <!-- Feedback Alert Section -->
        <div id="alert-placeholder"></div>

        <!-- Seller Profile Section -->
        <div class="text-center mb-4">
            <h1 class="display-5">Seller Profile</h1>
        </div>

        <!-- Display seller game -->
        @if (isset($game))
            <div id="seller-game-container">
                @include('partials.game-display', ['game' => $game])
            </div>
        @else
            <p class="text-center">No game available.</p>
        @endif

        <!-- Promotion Section -->
        <div class="card mt-4">
            <div class="card-body">
                <!-- Header Section -->
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="card-title">Create Promotion</h5>
                    <!-- End Promotion Button -->
                    <form action="{{ route('promotions.end') }}" method="POST" style="width: 150px;">
                        @csrf
                        <input type="hidden" name="game_id" value="{{ $game->id }}">
                        <button type="submit" class="btn btn-outline-danger w-100 h-auto">End Promotion</button>
                    </form>
                </div>
                <!-- Create Promotion Form -->
                <form action="{{ route('promotions.create') }}" method="POST" class="mt-3">
                    @csrf
                    <input type="hidden" name="game_id" value="{{ $game->id }}">

                    <!-- Input and Buttons Row -->
                    <div class="d-flex align-items-center">
                        <!-- Label -->
                        <label for="discount_percentage" class="form-label mb-0 me-3"
                            style="min-width: 180px; text-align: right;">
                            Discount Percentage
                        </label>
                        <!-- Discount Input -->
                        <div class="me-3" style="flex-grow: 1;">
                            <input type="number" class="form-control" id="discount_percentage" name="discount_percentage"
                                min="5" max="100" step="1" value="5">
                        </div>
                        <!-- Create Promotion Button -->
                        <button type="submit" class="btn btn-outline-dark" style="width: 150px;" class="h-auto">Create
                            Promotion</button>
                    </div>
                </form>
            </div>
        </div>


        <!-- Stock Section -->
        <div class="card mt-4">
            <div class="card-body">
                <h5 class="card-title">Manage Stock</h5>
                <form action="{{ route('games.updateStock', ['id' => $game->id]) }}" method="POST">
                    @csrf
                    @method('PUT')
                    <div class="d-flex align-items-center">
                        <label for="stock" class="form-label me-3 mb-0">Current Stock: {{ $game->stock }}</label>
                        <input type="number" class="form-control me-3" id="stock" name="stock" min="1" max="1000" value="1"
                            style="flex-grow: 1;">
                        <button type="submit" class="btn btn-outline-dark">Add Stock</button>
                    </div>
                </form>
            </div>
        </div>


        <!-- Game Stats Section -->
        @if (isset($game))
            <div class="card mt-4">
                <div class="card-body">
                    <h5 class="card-title">Game Stats</h5>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th scope="col">Metric</th>
                                <th scope="col">Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Sold Copies</td>
                                <td id="sold-copies">Loading...</td>
                            </tr>
                            <tr>
                                <td>Total Earnings</td>
                                <td id="total-earnings">Loading...</td>
                            </tr>
                        </tbody>
                    </table>
                    <canvas id="earningsChart" width="400" height="200"></canvas>
                </div>
            </div>
        @endif

        <!-- Game Purchase History Section -->
        <div class="card mt-4">
            <div class="card-body">
                <h5 class="card-title">Purchase History</h5>
                <!-- Search Bar -->
                <form class="search-form d-flex w-100 mb-2" action="{{ route('seller.home', ['id' => $game->id]) }}"
                    method="GET" id="purchase-history-form">
                    <div class="search-text d-flex w-100">
                        <input class="fd-flex w-100" type="text" name="query" placeholder="Search users"
                            value="{{ request('query') }}">
                    </div>
                    <button type="submit"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th scope="col">Date</th>
                            <th scope="col">Copies Sold</th>
                            <th scope="col">Price</th>
                            <th scope="col">Buyer</th>
                        </tr>
                    </thead>
                    <tbody id="purchase-history">
                        <!-- Purchase history will be populated here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const game = @json($game);
            let earningsChart;

            function updateGameStats() {
                fetch(`/games/${game.id}/stats`)
                    .then(response => response.json())
                    .then(data => {
                        if (!Array.isArray(data.soldCopies)) {
                            throw new Error('Invalid data format');
                        }
                        
                        document.getElementById("sold-copies").textContent = data.totalCopiesSold;
                        document.getElementById("total-earnings").textContent = data.totalEarnings.toFixed(2) + " €";

                        // Destroy the previous chart instance if it exists
                        if (earningsChart) {
                            earningsChart.destroy();
                        }

                        // Chart.js setup
                        const ctx = document.getElementById('earningsChart').getContext('2d');
                        earningsChart = new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels: data.soldCopies.map(day => day.date),
                                datasets: [{
                                    label: 'Copies Sold',
                                    data: data.soldCopies.map(day => day.copies_sold),
                                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                                    borderColor: 'rgba(75, 192, 192, 1)',
                                    borderWidth: 1,
                                    fill: false,
                                    tension: 0.1
                                }]
                            },
                            options: {
                                scales: {
                                    x: {
                                        type: 'time',
                                        time: {
                                            unit: 'day'
                                        },
                                        title: {
                                            display: true,
                                            text: 'Date'
                                        }
                                    },
                                    y: {
                                        beginAtZero: true,
                                        title: {
                                            display: true,
                                            text: 'Copies Sold'
                                        }
                                    }
                                },
                                plugins: {
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                const day = context.raw;
                                                return `Date: ${context.label}, Copies Sold: ${context.raw}, Total Earnings: ${(context.raw * game.price).toFixed(2)} €`;
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    })
                    .catch(error => console.error("Error fetching game stats:", error));
            }

            function updatePurchaseHistory(query = '') {
                fetch(`/games/${game.id}/purchase-history?query=${query}`)
                    .then(response => response.json())
                    .then(data => {
                        const purchaseHistoryContainer = document.getElementById("purchase-history");
                        purchaseHistoryContainer.innerHTML = data.purchaseHistory.map(purchase => `
                            <tr>
                                <td>${purchase.date}</td>
                                <td>${purchase.copies_sold}</td>
                                <td>${purchase.total_earnings} €</td>
                                <td>${purchase.buyer_name}</td>
                            </tr>
                        `).join('');
                    })
                    .catch(error => console.error("Error fetching purchase history:", error));
            }

            // Initial display
            updateGameStats();
            updatePurchaseHistory();

            // Fetch purchase history on form submit
            document.getElementById('purchase-history-form').addEventListener('submit', function (event) {
                event.preventDefault();
                const form = event.target;
                const query = new URLSearchParams(new FormData(form)).get('query');
                updatePurchaseHistory(query);
            });
        });
    </script>
@else
    <div class="container">
        <h1>Unauthorized Access</h1>
        <p>You are not authorized to view this page.</p>
    </div>
@endif
@endsection