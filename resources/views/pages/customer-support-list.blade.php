@extends('layouts.app')

@section('content')
<div class="container">
    <h1>Support Messages</h1>

    <table class="table">
        <thead>
            <tr>
                <th>#</th>
                <th>Message</th>
                <th>Type</th>
                <th>Date</th>
                <th>Buyer</th>
            </tr>
        </thead>
        <tbody>
            @foreach($messages as $message)
                <tr>
                    <td>{{ $message->id }}</td>
                    <td>{{ $message->message }}</td>
                    <td>{{ $message->type }}</td>
                    <td>{{ $message->help_date }}</td>
                    <td>{{ $message->buyer->name ?? 'Anonymous' }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</div>
@endsection