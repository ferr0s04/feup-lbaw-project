<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            text-align: center;
        }

        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #333;
            font-size: 24px;
            margin-bottom: 20px;
        }

        p {
            color: #555;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 30px;
        }

        .reset-link {
            display: inline-block;
            background-color: #4CAF50;
            color: #fff;
            padding: 10px 20px;
            text-decoration: none;
            font-size: 16px;
            border-radius: 4px;
            transition: background-color 0.3s ease;
        }

        .reset-link:hover {
            background-color: #45a049;
        }

        footer {
            margin-top: 20px;
            font-size: 14px;
            color: #777;
        }

    </style>
</head>
<body>
    <div class="email-container">
        <h1>Password Reset Request</h1>
        <p>We received a request to reset your password. Click the button below to reset it:</p>
        <a href="{{ url('password/reset/'.$token) }}" class="reset-link">Reset My Password</a>
        <footer>
            <p>If you didn't request a password reset, please ignore this email.</p>
        </footer>
    </div>
</body>
</html>
