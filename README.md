# Home Tuition Platform - Backend

A comprehensive Laravel-based backend API for a multi-role home tuition platform connecting students, teachers, referral agents, and administrators.

## Features

- 🔐 **OTP-based Authentication** - Secure phone number verification
- 📍 **Location-based Matching** - Auto-match teachers to students using Haversine formula
- 💰 **Commission Management** - Automated payment distribution to teachers and agents
- 📊 **Role-based Access Control** - Separate permissions for Admin, Teacher, Student, and Agent
- 💳 **Wallet System** - Built-in wallet for teachers and agents
- 📅 **Attendance Tracking** - Daily attendance with geo-location support
- 📝 **Test Management** - Create and grade tests with performance analytics
- 🔔 **Notifications** - Push notification system
- 📈 **Analytics Dashboard** - Comprehensive statistics for all roles

## Tech Stack

- **Framework**: Laravel 11.x
- **Database**: MySQL 8.0+
- **PHP**: 8.2+
- **Authentication**: Laravel Sanctum
- **Deployment**: GitHub Actions + Hostinger FTP

## Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tuition-platform-backend
   ```

2. **Install dependencies**
   ```bash
   composer install
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Configure database**
   Edit `.env` file:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=tuition_platform
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. **Run migrations**
   ```bash
   php artisan migrate
   ```

6. **Seed database (optional)**
   ```bash
   php artisan db:seed
   ```

7. **Start development server**
   ```bash
   php artisan serve
   ```

   API will be available at `http://localhost:8000`

## Database Schema

### Core Tables

- **users** - Base user table with roles (admin, teacher, student, parent, agent)
- **teachers** - Teacher profiles with location and qualifications
- **students** - Student profiles with location and requirements
- **agents** - Referral agent profiles with commission tracking
- **tuition_requests** - Student tuition requests
- **leads** - Teacher-student matching leads
- **demo_classes** - Demo class scheduling and feedback
- **paid_tuitions** - Active paid tuition records
- **attendances** - Daily attendance tracking
- **tests** - Test management
- **test_results** - Student test scores and rankings
- **wallets** - User wallet balances
- **transactions** - Financial transaction logs
- **payout_requests** - Withdrawal requests
- **notifications** - Push notifications
- **otp_verifications** - OTP authentication
- **commission_settings** - System-wide commission configuration
- **teacher_leaves** - Teacher leave management

## API Documentation

### Authentication

#### Send OTP
```http
POST /api/auth/send-otp
Content-Type: application/json

{
  "phone": "+919876543210"
}
```

#### Verify OTP
```http
POST /api/auth/verify-otp
Content-Type: application/json

{
  "phone": "+919876543210",
  "otp": "123456"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "phone": "+919876543210",
  "otp": "123456"
}
```

### Teacher Endpoints

- `GET /api/teacher/dashboard` - Dashboard statistics
- `GET /api/teacher/leads` - View available leads
- `POST /api/teacher/leads/{id}/accept` - Accept a lead
- `POST /api/teacher/leads/{id}/reject` - Reject a lead
- `GET /api/teacher/demo-classes` - View demo classes
- `POST /api/teacher/attendance` - Mark attendance
- `GET /api/teacher/wallet` - View wallet balance
- `POST /api/teacher/payout` - Request payout

### Student Endpoints

- `POST /api/student/tuition-request` - Create tuition request
- `GET /api/student/demo-classes` - View demo classes
- `POST /api/student/demo-feedback` - Submit demo feedback
- `GET /api/student/attendance` - View attendance
- `GET /api/student/tests` - View tests and results

### Admin Endpoints

- `GET /api/admin/dashboard` - Admin dashboard statistics
- `GET /api/admin/teachers` - Manage teachers
- `POST /api/admin/teachers/{id}/approve` - Approve teacher
- `GET /api/admin/students` - Manage students
- `GET /api/admin/leads` - View all leads
- `POST /api/admin/leads/auto-match` - Auto-match teachers
- `GET /api/admin/payouts` - View payout requests
- `POST /api/admin/payouts/{id}/approve` - Approve payout

### Agent Endpoints

- `GET /api/agent/dashboard` - Agent dashboard
- `GET /api/agent/referrals` - View referrals
- `GET /api/agent/wallet` - View commission earnings
- `POST /api/agent/payout` - Request payout

## Deployment to Hostinger

### Prerequisites

1. Hostinger shared hosting account
2. MySQL database created on Hostinger
3. FTP/SFTP credentials
4. GitHub repository

### Setup GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `FTP_SERVER` - Your Hostinger FTP server (e.g., ftp.yourdomain.com)
- `FTP_USERNAME` - FTP username
- `FTP_PASSWORD` - FTP password
- `FTP_SERVER_DIR` - Server directory path (e.g., /public_html/api/)
- `SSH_HOST` - SSH host (if available)
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `SSH_PORT` - SSH port (usually 22)

### Environment Configuration

1. Create `.env.production` file with production settings:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://yourdomain.com
   
   DB_CONNECTION=mysql
   DB_HOST=localhost
   DB_PORT=3306
   DB_DATABASE=your_database_name
   DB_USERNAME=your_database_user
   DB_PASSWORD=your_database_password
   ```

2. Upload `.env` file to Hostinger via FTP

### Deploy

1. Push to main branch:
   ```bash
   git push origin main
   ```

2. GitHub Actions will automatically:
   - Run tests
   - Install dependencies
   - Deploy via FTP
   - Run migrations
   - Optimize caches

### Manual Deployment

If you prefer manual deployment:

1. **Build locally**
   ```bash
   composer install --no-dev --optimize-autoloader
   ```

2. **Upload via FTP**
   - Upload all files except `.git`, `node_modules`, `tests`
   - Upload `.env.production` as `.env`

3. **Run migrations via SSH**
   ```bash
   php artisan migrate --force
   php artisan config:cache
   php artisan route:cache
   php artisan optimize
   ```

## Location-Based Matching

The platform uses the Haversine formula to calculate distances between students and teachers:

```php
$teachers = Teacher::nearLocation($latitude, $longitude, $radiusKm)
    ->bySubject('Math')
    ->byClass('10')
    ->get();
```

Match scoring considers:
- **Distance** (40 points) - Closer is better
- **Rating** (30 points) - Higher ratings score better
- **Experience** (20 points) - More experience is better
- **Availability** (10 points) - Fewer students is better

## Commission Flow

Example with ₹3000 monthly fee:

1. Student pays ₹3000
2. System calculates:
   - Admin commission: ₹1000 (33.33%)
   - Teacher salary: ₹2000 (66.67%)
   - Agent commission: ₹300 (10% if referred)
3. Credits to respective wallets
4. Teachers/Agents request payout
5. Admin approves payout

## Testing

Run tests:
```bash
php artisan test
```

Run specific test suite:
```bash
php artisan test --filter=AuthTest
php artisan test --testsuite=Feature
```

## Security

- OTP-based authentication
- JWT tokens via Laravel Sanctum
- Role-based access control
- SQL injection protection (Eloquent ORM)
- CSRF protection
- Rate limiting on API endpoints

## Performance Optimization

- Database indexing on frequently queried columns
- Query optimization with eager loading
- Route caching
- Config caching
- View caching
- Opcode caching (OPcache)

## Support

For issues and questions, please create an issue in the GitHub repository.

## License

Proprietary - All rights reserved
