<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Notification</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f7f7;
            margin: 0;
            padding: 0;
        }
        table {
            width: 100%;
            max-width: 600px;
            margin: 20px auto;
            border-collapse: collapse;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        td {
            padding: 20px;
            text-align: left;
        }
        h1 {
            color: #4CAF50;
            font-size: 24px;
            margin: 0;
        }
        p {
            font-size: 16px;
            color: #333333;
            line-height: 1.5;
        }
        @media (max-width: 600px) {
            table {
                width: 100%;
                padding: 10px;
            }
            h1 {
                font-size: 20px;
            }
            p {
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <table>
        <tr>
            <td>
                <h1>New Notification</h1>
                <p>{{ $messageContent }}</p>
                <p>If you have any questions, feel free to reach out to us.</p>
            </td>
        </tr>
    </table>
</body>
</html>
