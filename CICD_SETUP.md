# CI/CD Pipeline Setup Guide

Complete guide for setting up automated deployment pipeline with GitHub Actions for the Home Tuition Platform.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Firebase Setup](#firebase-setup)
4. [GitHub Repository Setup](#github-repository-setup)
5. [Hostinger Configuration](#hostinger-configuration)
6. [GitHub Secrets Configuration](#github-secrets-configuration)
7. [Workflow Configuration](#workflow-configuration)
8. [Testing the Pipeline](#testing-the-pipeline)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The CI/CD pipeline automatically:
- ✅ Runs tests on every push
- ✅ Deploys to Hostinger via FTP
- ✅ Runs database migrations
- ✅ Optimizes Laravel caches
- ✅ Sends deployment notifications

**Deployment Flow:**
```
Push to GitHub → Tests Run → Build → Deploy via FTP → Migrations → Cache Optimization → Done
```

---

## Prerequisites

### Required Accounts
- ✅ GitHub account with repository access
- ✅ Hostinger shared hosting account
- ✅ Firebase project (for notifications)
- ✅ Domain configured with SSL

### Local Tools
- Git installed
- SSH client (for testing)
- FTP client (FileZilla recommended)

---

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project**
3. Enter project name: `tuition-platform`
4. Disable Google Analytics (optional)
5. Click **Create Project**

### 2. Enable Firebase Cloud Messaging

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Navigate to **Cloud Messaging** tab
3. Note down:
   - **Server Key** (for backend)
   - **Sender ID**

### 3. Generate Service Account Key

1. In Firebase Console → **Project Settings**
2. Go to **Service Accounts** tab
3. Click **Generate New Private Key**
4. Save the JSON file as `firebase-credentials.json`
5. **Keep this file secure!**

### 4. Add Firebase to Android App

1. In Firebase Console, click **Add App** → **Android**
2. Enter package name: `com.tuitionplatform.admin_app` (repeat for each app)
3. Download `google-services.json`
4. Place in `android/app/` directory of each Flutter app

### 5. Add Firebase to iOS App

1. In Firebase Console, click **Add App** → **iOS**
2. Enter bundle ID: `com.tuitionplatform.adminApp`
3. Download `GoogleService-Info.plist`
4. Add to Xcode project

---

## GitHub Repository Setup

### 1. Initialize Repository

```bash
cd tuition-platform-backend
git init
git add .
git commit -m "Initial commit with CI/CD pipeline"
```

### 2. Create GitHub Repository

1. Go to [GitHub](https://github.com/new)
2. Create new repository: `tuition-platform-backend`
3. **Do not** initialize with README (already exists)
4. Copy the repository URL

### 3. Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/tuition-platform-backend.git
git branch -M main
git push -u origin main
```

### 4. Create Staging Branch (Optional)

```bash
git checkout -b staging
git push -u origin staging
```

---

## Hostinger Configuration

### 1. Access Hostinger hPanel

1. Log in to [Hostinger](https://www.hostinger.com/)
2. Go to **Hosting** → Select your plan
3. Click **Manage**

### 2. Create MySQL Database

1. Navigate to **Databases** → **MySQL Databases**
2. Click **Create New Database**
3. Fill in:
   - **Database Name**: `u123456789_tuition`
   - **Username**: `u123456789_admin`
   - **Password**: Generate strong password
4. Click **Create**
5. **Save credentials securely**

### 3. Get FTP Credentials

1. Go to **Files** → **FTP Accounts**
2. Find your main FTP account or create new one
3. Note down:
   - **FTP Host**: `ftp.yourdomain.com`
   - **Username**: `u123456789`
   - **Password**: Your FTP password
   - **Port**: `21`

### 4. Get SSH Access (if available)

> **Note**: SSH typically available on Business plans and above

1. Go to **Advanced** → **SSH Access**
2. Enable SSH if not already enabled
3. Note down:
   - **SSH Host**: `ssh.yourdomain.com`
   - **SSH Port**: `65002` (or as shown)
   - **Username**: Same as FTP username

### 5. Configure Directory Structure

Via FTP, create this structure:
```
/public_html/
├── api/              # Laravel backend
│   └── public/       # Web root
├── admin/            # Admin Flutter web app
├── teacher/          # Teacher Flutter web app
├── student/          # Student Flutter web app
└── agent/            # Agent Flutter web app
```

### 6. Set Document Root

1. In hPanel, go to **Advanced** → **Domain Configuration**
2. Set document root to `/public_html/api/public`
3. Save changes

---

## GitHub Secrets Configuration

### 1. Access Repository Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### 2. Add Required Secrets

Add each of the following secrets:

#### FTP Credentials
```
Name: FTP_SERVER
Value: ftp.yourdomain.com

Name: FTP_USERNAME
Value: u123456789

Name: FTP_PASSWORD
Value: your_ftp_password

Name: FTP_SERVER_DIR
Value: /public_html/api/
```

#### SSH Credentials (if available)
```
Name: SSH_HOST
Value: ssh.yourdomain.com

Name: SSH_USERNAME
Value: u123456789

Name: SSH_PASSWORD
Value: your_ssh_password

Name: SSH_PORT
Value: 65002
```

#### Database Credentials
```
Name: DB_DATABASE
Value: u123456789_tuition

Name: DB_USERNAME
Value: u123456789_admin

Name: DB_PASSWORD
Value: your_database_password
```

#### Firebase Credentials
```
Name: FIREBASE_CREDENTIALS
Value: (paste entire content of firebase-credentials.json)
```

### 3. Verify Secrets

After adding all secrets, you should see:
- ✅ FTP_SERVER
- ✅ FTP_USERNAME
- ✅ FTP_PASSWORD
- ✅ FTP_SERVER_DIR
- ✅ SSH_HOST
- ✅ SSH_USERNAME
- ✅ SSH_PASSWORD
- ✅ SSH_PORT
- ✅ DB_DATABASE
- ✅ DB_USERNAME
- ✅ DB_PASSWORD
- ✅ FIREBASE_CREDENTIALS

---

## Workflow Configuration

### 1. Review Workflow File

The workflow is already created at `.github/workflows/deploy.yml`

Key sections:
```yaml
on:
  push:
    branches: [main, staging]  # Triggers
  workflow_dispatch:           # Manual trigger

jobs:
  deploy:
    steps:
      - Checkout code
      - Setup PHP
      - Install dependencies
      - Run tests
      - Deploy via FTP
      - Run migrations
      - Optimize caches
```

### 2. Customize Workflow (Optional)

Edit `.github/workflows/deploy.yml` to:

**Change PHP version:**
```yaml
- name: Setup PHP
  uses: shivammathur/setup-php@v2
  with:
    php-version: '8.3'  # Change version
```

**Add environment-specific deployment:**
```yaml
- name: Deploy to Staging
  if: github.ref == 'refs/heads/staging'
  # staging deployment steps

- name: Deploy to Production
  if: github.ref == 'refs/heads/main'
  # production deployment steps
```

**Add Slack notifications:**
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 3. Create Environment Files

Create `.env.production` in repository root:

```env
APP_NAME="Tuition Platform"
APP_ENV=production
APP_KEY=base64:WILL_BE_GENERATED
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

FIREBASE_CREDENTIALS=/home/u123456789/storage/firebase-credentials.json

# SMS Gateway
SMS_GATEWAY=msg91
MSG91_AUTH_KEY=your_msg91_key
MSG91_TEMPLATE_ID=your_template_id
```

**Important**: Add `.env.production` to `.gitignore` if it contains sensitive data!

---

## Testing the Pipeline

### 1. Test FTP Connection Locally

```bash
# Install lftp
brew install lftp  # macOS
# or
sudo apt install lftp  # Linux

# Test connection
lftp -u USERNAME,PASSWORD ftp.yourdomain.com
ls
exit
```

### 2. Test SSH Connection (if available)

```bash
ssh -p 65002 u123456789@ssh.yourdomain.com
cd public_html/api
php -v
exit
```

### 3. Manual Test Deployment

```bash
# Create test branch
git checkout -b test-deployment

# Make a small change
echo "# Test" >> README.md

# Commit and push
git add .
git commit -m "Test: CI/CD pipeline"
git push origin test-deployment
```

### 4. Trigger Workflow

**Option A: Push to main/staging**
```bash
git checkout main
git merge test-deployment
git push origin main
```

**Option B: Manual trigger**
1. Go to GitHub repository
2. Click **Actions** tab
3. Select **Deploy to Hostinger** workflow
4. Click **Run workflow**
5. Select branch
6. Click **Run workflow**

### 5. Monitor Deployment

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch each step execute
4. Check for errors (red X) or success (green checkmark)

### 6. Verify Deployment

```bash
# Check if files are deployed
lftp -u USERNAME,PASSWORD ftp.yourdomain.com
cd public_html/api
ls -la
exit

# Check website
curl https://yourdomain.com/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-01-16T13:00:00Z"
}
```

---

## Troubleshooting

### Issue: Workflow fails at "Setup PHP"

**Solution:**
- Check PHP version compatibility
- Ensure extensions are listed correctly
- Try using `shivammathur/setup-php@v2`

### Issue: "composer install" fails

**Solution:**
```yaml
- name: Install Composer dependencies
  run: |
    composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs
```

### Issue: FTP deployment fails

**Possible causes:**
1. **Wrong credentials** → Verify FTP secrets
2. **Directory doesn't exist** → Create via FTP client
3. **Permissions issue** → Check folder permissions (755)
4. **Firewall blocking** → Contact Hostinger support

**Debug steps:**
```bash
# Test FTP manually
ftp ftp.yourdomain.com
# Enter username and password
ls
cd public_html/api
pwd
exit
```

### Issue: SSH commands fail

**Solution:**
- Verify SSH is enabled in hPanel
- Check SSH port (usually 65002, not 22)
- Ensure SSH secrets are correct
- Try manual SSH connection first

### Issue: Migrations don't run

**Possible causes:**
1. **Database connection failed** → Check DB credentials
2. **SSH not available** → Use alternative migration method
3. **Permissions issue** → Check file permissions

**Alternative: Web-based migration**

Create `migrate.php` in public directory:
```php
<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->call('migrate', ['--force' => true]);
echo "Migrations completed!";
```

Access: `https://yourdomain.com/migrate.php`
**Delete after use!**

### Issue: "Permission denied" errors

**Solution:**
```bash
# Via SSH
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Via FTP
# Right-click folders → Permissions → 755
```

### Issue: Cache not clearing

**Solution:**
Add to workflow:
```yaml
- name: Clear all caches
  run: |
    php artisan cache:clear
    php artisan config:clear
    php artisan route:clear
    php artisan view:clear
    php artisan optimize:clear
```

### Issue: Environment variables not loading

**Solution:**
1. Ensure `.env` file exists on server
2. Check file permissions (644)
3. Verify `APP_KEY` is set:
   ```bash
   php artisan key:generate
   ```

---

## Advanced Configuration

### 1. Multiple Environments

Create separate workflows for staging and production:

**.github/workflows/deploy-staging.yml**
```yaml
name: Deploy to Staging
on:
  push:
    branches: [staging]
```

**.github/workflows/deploy-production.yml**
```yaml
name: Deploy to Production
on:
  push:
    branches: [main]
```

### 2. Rollback Procedure

Add rollback workflow:

**.github/workflows/rollback.yml**
```yaml
name: Rollback Deployment
on:
  workflow_dispatch:
    inputs:
      commit:
        description: 'Commit SHA to rollback to'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout specific commit
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.inputs.commit }}
      
      # ... rest of deployment steps
```

### 3. Database Backup Before Migration

Add to workflow:
```yaml
- name: Backup Database
  run: |
    ssh -p ${{ secrets.SSH_PORT }} ${{ secrets.SSH_USERNAME }}@${{ secrets.SSH_HOST }} \
    "mysqldump -u ${{ secrets.DB_USERNAME }} -p'${{ secrets.DB_PASSWORD }}' \
    ${{ secrets.DB_DATABASE }} > ~/backups/db_$(date +%Y%m%d_%H%M%S).sql"
```

### 4. Slack Notifications

Add to workflow:
```yaml
- name: Notify Slack on Success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: custom
    custom_payload: |
      {
        text: '✅ Deployment successful!',
        attachments: [{
          color: 'good',
          text: `Deployed to production by ${{ github.actor }}`
        }]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

- name: Notify Slack on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: custom
    custom_payload: |
      {
        text: '❌ Deployment failed!',
        attachments: [{
          color: 'danger',
          text: `Check the logs: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}`
        }]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Security Best Practices

### 1. Secrets Management
- ✅ Never commit secrets to repository
- ✅ Use GitHub Secrets for all sensitive data
- ✅ Rotate credentials regularly
- ✅ Use different credentials for staging/production

### 2. Access Control
- ✅ Limit who can trigger workflows
- ✅ Require pull request reviews
- ✅ Enable branch protection rules
- ✅ Use environment-specific secrets

### 3. Deployment Safety
- ✅ Always run tests before deployment
- ✅ Backup database before migrations
- ✅ Have rollback procedure ready
- ✅ Monitor deployment logs

---

## Monitoring & Maintenance

### 1. Monitor Deployments

- Check GitHub Actions regularly
- Set up email notifications for failures
- Review deployment logs weekly

### 2. Regular Updates

```bash
# Update dependencies monthly
composer update
git add composer.lock
git commit -m "Update dependencies"
git push origin main
```

### 3. Performance Monitoring

- Monitor API response times
- Check database query performance
- Review error logs regularly

---

## Quick Reference

### Common Commands

```bash
# Trigger deployment
git push origin main

# View workflow runs
gh run list

# View specific run
gh run view RUN_ID

# Re-run failed workflow
gh run rerun RUN_ID

# Cancel running workflow
gh run cancel RUN_ID
```

### Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Hostinger Knowledge Base](https://support.hostinger.com/)
- [Laravel Deployment](https://laravel.com/docs/deployment)
- [Firebase Console](https://console.firebase.google.com/)

---

## Checklist

Before going live, ensure:

- [ ] All GitHub secrets configured
- [ ] Firebase project created and configured
- [ ] Database created on Hostinger
- [ ] FTP/SSH access tested
- [ ] Workflow runs successfully
- [ ] Migrations execute correctly
- [ ] SSL certificate installed
- [ ] Domain pointing to correct directory
- [ ] Environment variables set
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Team has access to necessary credentials

---

**Last Updated**: January 16, 2026

For support, create an issue in the GitHub repository.
