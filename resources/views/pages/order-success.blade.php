@extends('layouts.app')

@section('order-success')
    <div class="order-success">
        <i class="fa-regular fa-circle-check"></i>
        <h2>Order Confirmed!</h2>
        <p>Thank you for your order. Your payment was successfully processed.</p>
        <a href="/" class="btn-primary">Go to Home</a>
    </div>
@endsection
