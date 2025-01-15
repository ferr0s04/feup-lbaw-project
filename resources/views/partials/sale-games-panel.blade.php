@extends('layouts.app')

@section('content')
<h1 class="textdiuted">Sales</h1>
<div class="row">
    @foreach($sales as $index => $game)
        @include('partials.game-display', ['game' => $game]) 
    @endforeach
</div>

@endsection            