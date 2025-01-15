@extends('layouts.app')

@section('content')
<div class="contact-container">
    <h1>Contact Us</h1>
    <p>We’d love to hear from you! Please use the form below to get in touch with us for any questions, feedback, or support.</p>

    <form method="POST" action="{{ route('contact.submit') }}">
        @csrf

        <!-- Name Field -->
        <div class="form-group">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" class="form-control" placeholder="Your Full Name" required>
        </div>

        <!-- Email Field -->
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" class="form-control" placeholder="Your Email Address" required>
        </div>

        <!-- Subject Field -->
        <div class="form-group">
            <label for="subject">Subject:</label>
            <input type="text" id="subject" name="subject" class="form-control" placeholder="Subject" required>
        </div>

        <!-- Message Field -->
        <div class="form-group">
            <label for="message">Message:</label>
            <textarea id="message" name="message" class="form-control" rows="5" placeholder="Your Message" required></textarea>
        </div>

        <!-- Submit Button -->
        <div class="form-group">
            <button type="submit" class="btn btn-primary">Send Message</button>
        </div>
    </form>
</div>
@endsection

