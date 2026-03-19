<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Certificate</title>
    <style>
        @page { margin: 0; }
        body {
            margin: 0;
            padding: 0;
            font-family: 'Helvetica', sans-serif;
            background-color: #f4f4f4;
        }
        .container {
            width: 100%;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px;
            box-sizing: border-box;
        }
        .certificate {
            width: 800px;
            height: 600px;
            background: white;
            border: 20px solid #d4af37; /* Gold border */
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            position: relative;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .certificate::before {
            content: "";
            position: absolute;
            top: 10px;
            left: 10px;
            right: 10px;
            bottom: 10px;
            border: 2px solid #d4af37;
        }
        .header h1 {
            color: #d4af37;
            font-size: 50px;
            margin: 0;
            text-transform: uppercase;
        }
        .header p {
            font-size: 20px;
            color: #555;
            margin-top: 10px;
        }
        .content {
            margin-top: 50px;
        }
        .content p {
            font-size: 24px;
            margin: 10px 0;
        }
        .name {
            font-size: 40px;
            font-weight: bold;
            color: #333;
            text-decoration: underline;
            margin: 20px 0;
        }
        .reason {
            font-size: 18px;
            color: #666;
            font-style: italic;
            margin-top: 30px;
        }
        .footer {
            position: absolute;
            bottom: 60px;
            left: 0;
            right: 0;
            display: flex;
            justify-content: space-around;
        }
        .signature {
            border-top: 1px solid #333;
            width: 200px;
            margin: 0 50px;
            font-size: 16px;
            color: #333;
            padding-top: 5px;
        }
        .logo {
            margin-top: 20px;
            font-size: 24px;
            font-weight: bold;
            color: #d4af37;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="certificate">
            <div class="header">
                <h1>Certificate of Excellence</h1>
                <p>Awarded to</p>
            </div>
            
            <div class="content">
                <div class="name">{{ $name }}</div>
                <p>In recognition of outstanding academic performance</p>
                <div class="reason">{{ $reason }}</div>
            </div>

            <div class="footer">
                <div style="float: left; width: 50%;">
                    <div class="signature">Academic Director</div>
                </div>
                <div style="float: right; width: 50%;">
                    <div class="signature">Date: {{ $date }}</div>
                </div>
            </div>

            <div style="clear: both; margin-top: 150px;">
                <div class="logo">Tuition Platform</div>
            </div>
        </div>
    </div>
</body>
</html>
