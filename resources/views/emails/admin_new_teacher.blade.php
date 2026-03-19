<!DOCTYPE html>
<html>
<head>
    <title>New Teacher Registration</title>
</head>
<body>
    <h1>New Teacher Registered</h1>
    <p>A new teacher has registered and is awaiting approval:</p>
    <ul>
        <li><strong>Name:</strong> {{ $name }}</li>
        <li><strong>Phone:</strong> {{ $phone }}</li>
        <li><strong>WhatsApp:</strong> {{ $whatsapp }}</li>
        <li><strong>Email:</strong> {{ $email }}</li>
    </ul>
    <p>Please log in to the admin panel to review and approve the application.</p>
</body>
</html>
