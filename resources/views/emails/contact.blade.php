<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $subject }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }
        .container {
            width: 100%;
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        h2 {
            color: #4CAF50;
            font-size: 24px;
            margin-bottom: 10px;
        }
        h4 {
            color: #333;
            font-size: 18px;
            margin-top: 20px;
        }
        p {
            font-size: 16px;
            color: #555;
        }
        .highlight {
            font-weight: bold;
        }
        .footer {
            font-size: 12px;
            color: #999;
            text-align: center;
            margin-top: 30px;
        }
        @media screen and (max-width: 600px) {
            .container {
                width: 90%;
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Contact Message from: {{ $name }}</h2>
        <p><span class="highlight">Email:</span> {{ $email }}</p>
        <h4>Message:</h4>
        <p>{{ $messageContent }}</p>
        
        <div class="footer">
            <p>Sent from the website contact form</p>
        </div>
    </div>
</body>
</html>
