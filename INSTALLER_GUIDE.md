# Web Installer Guide

## Overview

The Tuition Platform includes a **web-based installer** that automatically sets up your application when you first visit your domain. No command-line access required!

---

## Installation Flow

```
Visit Domain → Auto-redirect to Installer → Complete Setup → Ready to Use
```

---

## Step-by-Step Installation

### 1. Upload Files to Server

Upload all backend files to your hosting server:

**Via FTP:**
```
/public_html/
└── (all Laravel files here)
```

**Important:** Upload the entire Laravel project, not just the `public` folder.

### 2. Set Document Root

In your hosting control panel (hPanel):
1. Go to **Advanced** → **Domain Configuration**
2. Set document root to: `/public_html/public`
3. Save changes

### 3. Set Permissions

Via FTP, set these permissions:
```
storage/                → 755 (recursive)
bootstrap/cache/        → 755 (recursive)
```

### 4. Visit Your Domain

Open your browser and go to:
```
https://yourdomain.com
```

You'll be automatically redirected to the installer.

---

## Installer Steps

### Step 1: Welcome Screen
- Click **"Get Started"**

### Step 2: Requirements Check
The installer checks:
- ✓ PHP Version (>= 8.2)
- ✓ Required PHP extensions
- ✓ Directory permissions

**If any requirement fails:**
- Contact your hosting provider
- Or fix permissions via FTP

### Step 3: Database Configuration
Enter your MySQL database details:

| Field | Example | Where to Find |
|-------|---------|---------------|
| Database Host | `localhost` | Usually "localhost" |
| Database Name | `u123456_tuition` | hPanel → Databases |
| Database Username | `u123456_admin` | hPanel → Databases |
| Database Password | `your_password` | Set when creating database |

Click **"Test Connection & Continue"**

### Step 4: Admin Account
Create your admin account:

| Field | Example |
|-------|---------|
| Admin Name | `John Doe` |
| Admin Phone | `+919876543210` |
| Admin Email | `admin@example.com` |

**Important:** Use phone number with country code (e.g., +91 for India)

Click **"Create Admin & Install"**

### Step 5: Installation
The installer will:
1. ✓ Create `.env` file
2. ✓ Generate application key
3. ✓ Create database tables
4. ✓ Create admin user
5. ✓ Set up wallet
6. ✓ Mark as installed

This takes 10-30 seconds.

### Step 6: Complete!
Installation successful! You'll see:
- ✅ Your admin login details
- 📱 Instructions for first login

Click **"Go to Dashboard"**

---

## First Login

### Via Mobile App:
1. Open the Tuition Platform app
2. Enter your admin phone number
3. Request OTP
4. Enter OTP to login
5. Access admin features

### Via Web (Future):
1. Go to `https://yourdomain.com/admin`
2. Login with phone + OTP
3. Access admin panel

---

## What Gets Installed

### Database Tables
- `users` - All users (admin, teachers, students, etc.)
- `wallets` - User wallet balances
- Plus 16 more tables for full functionality

### Configuration
- `.env` file with your database credentials
- Application key for security
- Default settings

### Admin Account
- Full access to all features
- Can approve teachers/students
- Can manage commissions
- Can view all transactions

---

## Troubleshooting

### Issue: "Requirements not met"

**PHP Version too low:**
- Contact hosting provider to upgrade to PHP 8.2+
- Or change PHP version in hPanel

**Extensions missing:**
- Contact hosting support
- Usually pre-installed on good hosting

**Permission errors:**
```bash
# Via SSH (if available)
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Via FTP
Right-click folder → Permissions → 755
```

### Issue: "Database connection failed"

**Check:**
1. Database exists in hPanel
2. Username has access to database
3. Password is correct
4. Host is `localhost` (not 127.0.0.1)

**Create database:**
1. hPanel → Databases → MySQL Databases
2. Create new database
3. Create new user
4. Add user to database with ALL PRIVILEGES

### Issue: "Installation failed"

**Solutions:**
1. Delete `.env` file (if exists)
2. Delete `storage/installed` file (if exists)
3. Refresh installer page
4. Try again

### Issue: "Blank page after installation"

**Check:**
1. Document root is set to `/public_html/public`
2. `.htaccess` file exists in public folder
3. mod_rewrite is enabled (contact support)

---

## Post-Installation

### 1. Secure Your Installation

**Delete installer files (optional):**
```
public/install.php
public/installer/
```

**Or protect with password:**
Create `.htaccess` in `public/installer/`:
```apache
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /path/to/.htpasswd
Require valid-user
```

### 2. Configure Firebase

1. Upload `firebase-credentials.json` to `storage/app/`
2. Update `.env`:
   ```
   FIREBASE_CREDENTIALS=/home/username/public_html/storage/app/firebase-credentials.json
   ```

### 3. Configure SMS Gateway

Update `.env`:
```
SMS_GATEWAY=msg91
MSG91_AUTH_KEY=your_key_here
MSG91_TEMPLATE_ID=your_template_id
```

### 4. Test the System

1. **Create test teacher:**
   - Use mobile app
   - Register as teacher
   - Admin approves via web

2. **Create test student:**
   - Use mobile app
   - Register as student
   - Request tuition

3. **Test notifications:**
   - Send test notification from admin
   - Verify receipt on mobile

---

## Reinstallation

If you need to reinstall:

1. **Delete installation marker:**
   ```
   storage/installed
   ```

2. **Delete .env file:**
   ```
   .env
   ```

3. **Drop database tables** (via phpMyAdmin):
   - Select all tables
   - Drop selected tables

4. **Visit domain again:**
   - Installer will run automatically

---

## Security Checklist

After installation:

- [ ] Change admin phone/email if needed
- [ ] Set up SSL certificate (Let's Encrypt)
- [ ] Configure firewall rules
- [ ] Set up regular backups
- [ ] Enable error logging
- [ ] Test OTP functionality
- [ ] Configure cron jobs for scheduler
- [ ] Review `.env` file permissions (644)

---

## Cron Job Setup

Add to cPanel → Cron Jobs:

```bash
* * * * * cd /home/username/public_html && php artisan schedule:run >> /dev/null 2>&1
```

This runs:
- Lead expiry cleanup
- Notification sending
- Payment reminders

---

## Support

### Common Issues

**500 Internal Server Error:**
- Check storage permissions (755)
- Check .htaccess file exists
- Enable error display in .env temporarily

**404 on all pages:**
- Check document root setting
- Verify mod_rewrite is enabled
- Check .htaccess file

**Database errors:**
- Verify credentials in .env
- Check database user permissions
- Ensure database exists

### Getting Help

1. Check error logs: `storage/logs/laravel.log`
2. Enable debug mode temporarily: `APP_DEBUG=true` in .env
3. Contact hosting support for server issues
4. Check Laravel documentation

---

## Next Steps

After successful installation:

1. **Configure commission rates** (via admin panel)
2. **Upload teacher verification documents**
3. **Set up payment gateway**
4. **Customize notification templates**
5. **Add terms & conditions**
6. **Create landing page content**

---

**Installation Time:** 5-10 minutes  
**Difficulty:** Easy (no technical knowledge required)  
**Requirements:** Web hosting with PHP 8.2+ and MySQL

---

**Last Updated:** January 16, 2026
