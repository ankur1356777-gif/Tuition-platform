<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tuition Platform - Installation</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .installer-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 14px;
        }
        
        .content {
            padding: 40px;
        }
        
        .step {
            display: none;
        }
        
        .step.active {
            display: block;
            animation: fadeIn 0.3s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        
        input[type="text"],
        input[type="password"],
        input[type="email"],
        select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        input:focus,
        select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        .btn-secondary {
            background: #e0e0e0;
            color: #333;
            margin-top: 10px;
        }
        
        .progress-bar {
            height: 4px;
            background: #e0e0e0;
            margin-bottom: 30px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s;
        }
        
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        
        .requirement {
            display: flex;
            align-items: center;
            padding: 12px;
            margin-bottom: 10px;
            border-radius: 8px;
            background: #f8f9fa;
        }
        
        .requirement-icon {
            width: 24px;
            height: 24px;
            margin-right: 12px;
            font-size: 18px;
        }
        
        .requirement-icon.success { color: #28a745; }
        .requirement-icon.error { color: #dc3545; }
        
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }
        
        .loading.active {
            display: block;
        }
        
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 16px;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .help-text {
            font-size: 12px;
            color: #666;
            margin-top: 4px;
        }
    </style>
</head>
<body>
    <div class="installer-container">
        <div class="header">
            <h1>🎓 Tuition Platform</h1>
            <p>Installation Wizard</p>
        </div>
        
        <div class="content">
            <div class="progress-bar">
                <div class="progress-fill" id="progressBar" style="width: 25%"></div>
            </div>
            
            <!-- Step 1: Welcome -->
            <div class="step active" id="step1">
                <h2 style="margin-bottom: 20px;">Welcome!</h2>
                <p style="margin-bottom: 20px; color: #666;">
                    This wizard will help you set up your Tuition Platform. The installation process includes:
                </p>
                <ul style="margin-bottom: 30px; padding-left: 20px; color: #666;">
                    <li style="margin-bottom: 10px;">✓ System requirements check</li>
                    <li style="margin-bottom: 10px;">✓ Database configuration</li>
                    <li style="margin-bottom: 10px;">✓ Admin account creation</li>
                    <li style="margin-bottom: 10px;">✓ Application setup</li>
                </ul>
                <button class="btn" onclick="nextStep(2)">Get Started</button>
            </div>
            
            <!-- Step 2: Requirements Check -->
            <div class="step" id="step2">
                <h2 style="margin-bottom: 20px;">System Requirements</h2>
                <div id="requirements"></div>
                <button class="btn" id="continueBtn" onclick="nextStep(3)" disabled>Continue</button>
                <button class="btn btn-secondary" onclick="checkRequirements()">Re-check Requirements</button>
            </div>
            
            <!-- Step 3: Database Configuration -->
            <div class="step" id="step3">
                <h2 style="margin-bottom: 20px;">Database Configuration</h2>
                <form id="dbForm">
                    <div class="form-group">
                        <label>Database Host</label>
                        <input type="text" name="db_host" value="localhost" required>
                        <div class="help-text">Usually "localhost" for shared hosting</div>
                    </div>
                    <div class="form-group">
                        <label>Database Name</label>
                        <input type="text" name="db_name" required>
                        <div class="help-text">Your MySQL database name</div>
                    </div>
                    <div class="form-group">
                        <label>Database Username</label>
                        <input type="text" name="db_username" required>
                    </div>
                    <div class="form-group">
                        <label>Database Password</label>
                        <input type="password" name="db_password">
                    </div>
                    <div id="dbError"></div>
                    <button type="submit" class="btn">Test Connection & Continue</button>
                    <button type="button" class="btn btn-secondary" onclick="prevStep(2)">Back</button>
                </form>
            </div>
            
            <!-- Step 4: Admin Account -->
            <div class="step" id="step4">
                <h2 style="margin-bottom: 20px;">Create Admin Account</h2>
                <form id="adminForm">
                    <div class="form-group">
                        <label>Admin Name</label>
                        <input type="text" name="admin_name" required>
                    </div>
                    <div class="form-group">
                        <label>Admin Phone (with country code)</label>
                        <input type="text" name="admin_phone" placeholder="+919876543210" required>
                        <div class="help-text">This will be used for login</div>
                    </div>
                    <div class="form-group">
                        <label>Admin Email</label>
                        <input type="email" name="admin_email" required>
                    </div>
                    <button type="submit" class="btn">Create Admin & Install</button>
                    <button type="button" class="btn btn-secondary" onclick="prevStep(3)">Back</button>
                </form>
            </div>
            
            <!-- Step 5: Installing -->
            <div class="step" id="step5">
                <div class="loading active">
                    <div class="spinner"></div>
                    <h3 style="margin-bottom: 10px;">Installing...</h3>
                    <p id="installStatus" style="color: #666;">Please wait while we set up your platform</p>
                </div>
            </div>
            
            <!-- Step 6: Complete -->
            <div class="step" id="step6">
                <div style="text-align: center;">
                    <div style="font-size: 64px; margin-bottom: 20px;">✅</div>
                    <h2 style="margin-bottom: 20px;">Installation Complete!</h2>
                    <div class="alert alert-success">
                        Your Tuition Platform has been successfully installed.
                    </div>
                    <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: left;">
                        <h3 style="margin-bottom: 15px;">Login Details:</h3>
                        <p style="margin-bottom: 10px;"><strong>Phone:</strong> <span id="adminPhoneDisplay"></span></p>
                        <p style="margin-bottom: 10px;"><strong>Email:</strong> <span id="adminEmailDisplay"></span></p>
                        <p style="color: #666; font-size: 14px; margin-top: 15px;">
                            An OTP will be sent to your phone number for login.
                        </p>
                    </div>
                    <button class="btn" onclick="window.location.href='/'">Go to Dashboard</button>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        let currentStep = 1;
        
        // Check requirements on load
        window.onload = function() {
            if (currentStep === 2) {
                checkRequirements();
            }
        };
        
        function nextStep(step) {
            document.getElementById('step' + currentStep).classList.remove('active');
            currentStep = step;
            document.getElementById('step' + currentStep).classList.add('active');
            updateProgress();
            
            if (step === 2) {
                checkRequirements();
            }
        }
        
        function prevStep(step) {
            nextStep(step);
        }
        
        function updateProgress() {
            const progress = (currentStep / 6) * 100;
            document.getElementById('progressBar').style.width = progress + '%';
        }
        
        async function checkRequirements() {
            const requirementsDiv = document.getElementById('requirements');
            requirementsDiv.innerHTML = '<div class="loading active"><div class="spinner"></div><p>Checking requirements...</p></div>';
            
            try {
                const response = await fetch('installer/check-requirements.php');
                const data = await response.json();
                
                let html = '';
                let allPassed = true;
                
                data.requirements.forEach(req => {
                    const icon = req.passed ? '✓' : '✗';
                    const iconClass = req.passed ? 'success' : 'error';
                    html += `
                        <div class="requirement">
                            <div class="requirement-icon ${iconClass}">${icon}</div>
                            <div>
                                <strong>${req.name}</strong>
                                <div class="help-text">${req.message}</div>
                            </div>
                        </div>
                    `;
                    if (!req.passed) allPassed = false;
                });
                
                requirementsDiv.innerHTML = html;
                document.getElementById('continueBtn').disabled = !allPassed;
                
                if (!allPassed) {
                    requirementsDiv.innerHTML += '<div class="alert alert-error" style="margin-top: 20px;">Please fix the requirements above before continuing.</div>';
                }
            } catch (error) {
                requirementsDiv.innerHTML = '<div class="alert alert-error">Error checking requirements. Please refresh the page.</div>';
            }
        }
        
        // Database form submission
        document.getElementById('dbForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const dbError = document.getElementById('dbError');
            
            dbError.innerHTML = '<div class="loading active"><div class="spinner"></div><p>Testing database connection...</p></div>';
            
            try {
                const response = await fetch('installer/test-database.php', {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                
                if (data.success) {
                    dbError.innerHTML = '<div class="alert alert-success">Database connection successful!</div>';
                    setTimeout(() => nextStep(4), 1000);
                } else {
                    dbError.innerHTML = '<div class="alert alert-error">' + data.message + '</div>';
                }
            } catch (error) {
                dbError.innerHTML = '<div class="alert alert-error">Connection failed. Please check your database credentials.</div>';
            }
        });
        
        // Admin form submission
        document.getElementById('adminForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            
            // Get database info from previous step
            const dbForm = document.getElementById('dbForm');
            const dbData = new FormData(dbForm);
            for (let pair of dbData.entries()) {
                formData.append(pair[0], pair[1]);
            }
            
            nextStep(5);
            
            try {
                const response = await fetch('installer/install.php', {
                    method: 'POST',
                    body: formData
                });
                const data = await response.json();
                
                if (data.success) {
                    document.getElementById('adminPhoneDisplay').textContent = formData.get('admin_phone');
                    document.getElementById('adminEmailDisplay').textContent = formData.get('admin_email');
                    nextStep(6);
                } else {
                    alert('Installation failed: ' + data.message);
                    prevStep(4);
                }
            } catch (error) {
                alert('Installation failed. Please try again.');
                prevStep(4);
            }
        });
    </script>
</body>
</html>
