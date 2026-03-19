# Deployment Guide - Home Tuition Platform

Complete guide for deploying the Home Tuition Platform to Hostinger shared hosting.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Hostinger Setup](#hostinger-setup)
3. [GitHub Repository Setup](#github-repository-setup)
4. [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
5. [Manual Deployment](#manual-deployment)
6. [Post-Deployment](#post-deployment)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- ✅ Hostinger shared hosting account
- ✅ GitHub account
- ✅ Domain name (configured with Hostinger)

### Local Development Tools
- PHP 8.2+
- Composer
- Git
- FTP client (FileZilla, Cyberduck, etc.)

---

## Hostinger Setup

### 1. Create MySQL Database

1. Log in to Hostinger control panel (hPanel)
2. Navigate to **Databases** → **MySQL Databases**
3. Click **Create New Database**
4. Fill in details:
   - **Database Name**: `tuition_platform`
   - **Username**: `tuition_user`
   - **Password**: Generate strong password
5. Note down the credentials

### 2. Get FTP Credentials

1. In hPanel, go to **Files** → **FTP Accounts**
2. Note down:
   - **FTP Host**: `ftp.yourdomain.com`
   - **Username**: Your FTP username
   - **Password**: Your FTP password
   - **Port**: 21

### 3. Get SSH Access (if available)

> **Note**: SSH is typically available on Business and higher plans

1. In hPanel, go to **Advanced** → **SSH Access**
2. Enable SSH if not already enabled
3. Note down SSH credentials

### 4. Configure Domain

1. Go to **Domains** in hPanel
2. Point your domain to the hosting
3. Set up SSL certificate (Let's Encrypt - free)
4. Configure document root to `/public_html/api/public` for API

---

## GitHub Repository Setup

### 1. Create Repository

```bash
cd tuition-platform-backend
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/tuition-platform-backend.git
git push -u origin main
```

### 2. Configure GitHub Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

| Secret Name | Value | Example |
|------------|-------|---------|
| `FTP_SERVER` | Your FTP host | `ftp.yourdomain.com` |
| `FTP_USERNAME` | FTP username | `user@yourdomain.com` |
| `FTP_PASSWORD` | FTP password | `your_ftp_password` |
| `FTP_SERVER_DIR` | Server directory | `/public_html/api/` |
| `SSH_HOST` | SSH host (if available) | `yourdomain.com` |
| `SSH_USERNAME` | SSH username | `your_ssh_user` |
| `SSH_PASSWORD` | SSH password | `your_ssh_password` |
| `SSH_PORT` | SSH port | `22` |

### 3. Create Environment File

Create `.env.production` in your repository root:

```env
APP_NAME="Tuition Platform"
APP_ENV=production
APP_KEY=base64:GENERATE_THIS_WITH_php_artisan_key:generate
APP_DEBUG=false
APP_URL=https://yourdomain.com

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=tuition_platform
DB_USERNAME=tuition_user
DB_PASSWORD=your_database_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

# SMS Gateway (MSG91 example)
SMS_GATEWAY=msg91
MSG91_AUTH_KEY=your_msg91_auth_key
MSG91_TEMPLATE_ID=your_template_id

# Firebase (for push notifications)
FIREBASE_CREDENTIALS=path/to/firebase-credentials.json

# Commission Settings (can be changed via admin panel)
ADMIN_COMMISSION_PERCENTAGE=33.33
TEACHER_SALARY_PERCENTAGE=66.67
AGENT_COMMISSION_PERCENTAGE=10.00
DEFAULT_MONTHLY_FEE=3000.00
```

---

## CI/CD Pipeline Configuration

The GitHub Actions workflow (`.github/workflows/deploy.yml`) will automatically:

1. ✅ Run tests
2. ✅ Install dependencies
3. ✅ Deploy to Hostinger via FTP
4. ✅ Run database migrations
5. ✅ Optimize caches

### Trigger Deployment

**Automatic deployment on push to main:**
```bash
git add .
git commit -m "Your changes"
git push origin main
```

**Manual deployment:**
1. Go to GitHub repository
2. Click **Actions** tab
3. Select **Deploy to Hostinger** workflow
4. Click **Run workflow**

### Monitor Deployment

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. View logs for each step
4. Check for errors

---

## Manual Deployment

If you prefer to deploy manually without CI/CD:

### 1. Prepare Files Locally

```bash
# Install dependencies (production only)
composer install --no-dev --optimize-autoloader

# Generate application key
php artisan key:generate

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### 2. Upload via FTP

Using FileZilla or any FTP client:

1. Connect to FTP server
2. Navigate to `/public_html/api/`
3. Upload all files **except**:
   - `.git/`
   - `node_modules/`
   - `tests/`
   - `.env.example`
   - `storage/logs/*` (keep directory structure)

4. Upload `.env.production` as `.env`

### 3. Set Permissions

Via FTP or SSH, set the following permissions:

```bash
chmod -R 755 storage
chmod -R 755 bootstrap/cache
```

### 4. Run Migrations

**Option A: Via SSH**
```bash
ssh your_username@yourdomain.com
cd public_html/api
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan optimize
```

**Option B: Via Web-based Terminal**
Some hosting providers offer web-based terminal in hPanel.

**Option C: Create Migration Script**
Create `migrate.php` in your root directory:

```php
<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->call('migrate', ['--force' => true]);
echo "Migrations completed!\n";
```

Access via browser: `https://yourdomain.com/migrate.php`
**Delete this file after running!**

---

## Post-Deployment

### 1. Verify Installation

Visit: `https://yourdomain.com/api/health`

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-01-16T12:00:00Z"
}
```

### 2. Create Admin User

Create `create-admin.php`:

```php
<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';

use App\Models\User;
use App\Models\Wallet;

$admin = User::create([
    'phone' => '+919876543210',
    'role' => 'admin',
    'name' => 'Admin',
    'email' => 'admin@yourdomain.com',
    'status' => 'approved',
    'phone_verified_at' => now(),
]);

Wallet::create([
    'user_id' => $admin->id,
    'balance' => 0,
]);

echo "Admin created successfully!\n";
echo "Phone: +919876543210\n";
```

Access: `https://yourdomain.com/create-admin.php`
**Delete this file after running!**

### 3. Test API Endpoints

```bash
# Send OTP
curl -X POST https://yourdomain.com/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}'

# Verify OTP
curl -X POST https://yourdomain.com/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "123456"}'
```

### 4. Configure Cron Jobs

In hPanel, go to **Advanced** → **Cron Jobs**

Add the following cron job to run Laravel scheduler:

```
* * * * * cd /home/username/public_html/api && php artisan schedule:run >> /dev/null 2>&1
```

This will handle:
- Expired lead cleanup
- Automated notifications
- Payment reminders

### 5. Set Up Backups

1. **Database Backup** (Daily)
   ```
   0 2 * * * mysqldump -u username -p'password' database_name > /path/to/backup/db_$(date +\%Y\%m\%d).sql
   ```

2. **Files Backup** (Weekly)
   - Use Hostinger's built-in backup feature
   - Or set up automated backups to cloud storage

---

## Troubleshooting

### Issue: 500 Internal Server Error

**Solution:**
1. Check `.env` file exists and is configured correctly
2. Check file permissions (755 for directories, 644 for files)
3. Check error logs: `/storage/logs/laravel.log`
4. Enable debug mode temporarily:
   ```env
   APP_DEBUG=true
   ```
   **Remember to disable after debugging!**

### Issue: Database Connection Failed

**Solution:**
1. Verify database credentials in `.env`
2. Check if database exists in hPanel
3. Ensure `DB_HOST=localhost` (not 127.0.0.1)
4. Test connection:
   ```php
   php artisan tinker
   DB::connection()->getPdo();
   ```

### Issue: Migrations Not Running

**Solution:**
1. Check database user has proper permissions
2. Run migrations manually via SSH
3. Check migration table exists:
   ```sql
   SHOW TABLES LIKE 'migrations';
   ```

### Issue: FTP Deployment Fails

**Solution:**
1. Verify FTP credentials
2. Check server directory path
3. Ensure sufficient disk space
4. Try passive mode in FTP settings

### Issue: Routes Not Working (404 errors)

**Solution:**
1. Check `.htaccess` file exists in `/public` directory
2. Ensure mod_rewrite is enabled (contact Hostinger support)
3. Clear route cache:
   ```bash
   php artisan route:clear
   php artisan route:cache
   ```

### Issue: Storage/Uploads Not Working

**Solution:**
1. Create symbolic link:
   ```bash
   php artisan storage:link
   ```
2. Set proper permissions:
   ```bash
   chmod -R 755 storage
   chmod -R 755 public/storage
   ```

---

## Performance Optimization

### 1. Enable OPcache

In hPanel → **PHP Configuration** → Enable OPcache

### 2. Optimize Composer Autoloader

```bash
composer install --optimize-autoloader --no-dev
```

### 3. Cache Configuration

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 4. Database Indexing

Ensure all migrations have proper indexes (already included in schema).

### 5. Use CDN for Assets

Consider using Cloudflare or similar CDN for static assets.

---

## Security Checklist

- ✅ `APP_DEBUG=false` in production
- ✅ Strong database passwords
- ✅ SSL certificate installed
- ✅ `.env` file not accessible via web
- ✅ Regular backups configured
- ✅ Rate limiting enabled on API routes
- ✅ CORS properly configured
- ✅ SQL injection protection (using Eloquent)
- ✅ XSS protection enabled
- ✅ CSRF protection enabled

---

## Monitoring & Maintenance

### 1. Error Monitoring

- Check `/storage/logs/laravel.log` regularly
- Set up email notifications for errors
- Consider using services like Sentry or Bugsnag

### 2. Performance Monitoring

- Monitor API response times
- Check database query performance
- Monitor disk space usage

### 3. Regular Updates

```bash
# Update dependencies
composer update

# Run migrations
php artisan migrate

# Clear caches
php artisan optimize:clear
php artisan optimize
```

---

## Support

For deployment issues:
1. Check Hostinger documentation
2. Contact Hostinger support
3. Review Laravel deployment documentation
4. Check GitHub Actions logs

---

## Rollback Procedure

If deployment fails:

1. **Via FTP**: Restore previous backup
2. **Via Git**: Revert to previous commit
   ```bash
   git revert HEAD
   git push origin main
   ```
3. **Database**: Restore from backup
   ```bash
   mysql -u username -p database_name < backup.sql
   ```

---

**Last Updated**: January 16, 2026
