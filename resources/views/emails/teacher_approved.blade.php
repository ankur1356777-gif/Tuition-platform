<!DOCTYPE html>
<html>
<head>
    <title>Account Approved</title>
</head>
<body>
    <h1>Congratulations {{ $name }}!</h1>
    <p>Your teacher account has been approved.</p>
    <p>You can now login to the application using your phone number <strong>{{ $phone }}</strong> and OTP.</p>
    
    <h3>Your System Generated Password</h3>
    <p>For web access (if applicable) or account recovery, use this password:</p>
    <p style="font-size: 24px; font-weight: bold; background: #eee; padding: 10px; display: inline-block;">{{ $password }}</p>

    <p>We recommend you keep this password safe.</p>
    
    <p>Regards,<br>Tuition Platform Team</p>
</body>
</html>
