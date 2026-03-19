<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Teacher;
use App\Models\Student;
use App\Models\Agent;
use App\Models\Lead;
use App\Models\TuitionRequest;
use App\Models\DemoClass;
use App\Models\Wallet;
use App\Models\Transaction;

class DemoContentSeeder extends Seeder
{
    public function run()
    {
        // 1. Create a Demo Teacher
        $teacherUser = User::firstOrCreate(
        ['phone' => '9876543210'],
        [
            'email' => 'teacher@demo.com',
            'name' => 'Amit Verma',
            'role' => 'teacher',
            'status' => 'approved',
            'phone_verified_at' => now(),
        ]
        );

        $teacher = Teacher::updateOrCreate(
        ['user_id' => $teacherUser->id],
        [
            'qualifications' => json_encode(['M.Sc. Physics', 'B.Ed']),
            'subjects' => json_encode(['Physics', 'Mathematics']),
            'classes' => json_encode(['9th', '10th', '11th', '12th']),
            'experience_years' => 5,
            'city' => 'Lucknow',
            'latitude' => 26.8467,
            'longitude' => 80.9462,
            'is_verified' => true
        ]
        );

        $wallet = Wallet::firstOrCreate(
        ['user_id' => $teacherUser->id],
        ['balance' => 1500.00]
        );

        // 2. Create a Demo Student
        $studentUser = User::firstOrCreate(
        ['phone' => '9876543211'],
        [
            'email' => 'student@demo.com',
            'name' => 'Rahul Singh',
            'role' => 'student',
            'status' => 'approved',
            'phone_verified_at' => now(),
        ]
        );

        $student = Student::firstOrCreate(
        ['user_id' => $studentUser->id],
        [
            'class' => '10th',
            'subjects_needed' => json_encode(['Math', 'Physics']),
            'school_name' => 'City Montessori School',
            'address' => 'Gomti Nagar, Lucknow',
            'city' => 'Lucknow',
            'state' => 'Uttar Pradesh',
            'pincode' => '226010',
            'latitude' => 26.8500,
            'longitude' => 80.9400,
        ]
        );

        // 3. Create a Tuition Request
        $request = TuitionRequest::create([
            'student_id' => $student->id,
            'subjects' => json_encode(['Physics']),
            'class' => '10th',
            'status' => 'matching',
            'created_at' => now()->subDays(2),
        ]);

        // 4. Create a Lead
        $lead = Lead::create([
            'teacher_id' => $teacher->id,
            'tuition_request_id' => $request->id,
            'status' => 'accepted',
            'match_score' => 95,
            'distance_km' => 2.5,
            'created_at' => now()->subDays(2),
            'sent_at' => now()->subDays(2),
            'expires_at' => now()->addDays(2),
        ]);

        // 5. Create a Scheduled Demo
        DemoClass::create([
            'lead_id' => $lead->id,
            'tuition_request_id' => $request->id,
            'student_id' => $student->id,
            'teacher_id' => $teacher->id,
            'scheduled_at' => now()->addDays(1)->format('Y-m-d H:i:s'), // Tomorrow
            'status' => 'scheduled',
            'teacher_feedback' => null,
        ]);

        // 6. Create Transactions
        Transaction::create([
            'user_id' => $teacherUser->id,
            'wallet_id' => $wallet->id,
            'amount' => 500,
            'type' => 'credit',
            'category' => 'salary_credited',
            'balance_before' => 0,
            'balance_after' => 500,
            'description' => 'Tuition Fee - Grade 9 Math',
            'created_at' => now()->subDays(5),
        ]);

        Transaction::create([
            'user_id' => $teacherUser->id,
            'wallet_id' => $wallet->id,
            'amount' => 1000,
            'type' => 'credit',
            'category' => 'salary_credited',
            'balance_before' => 500,
            'balance_after' => 1500,
            'description' => 'Tuition Fee - Grade 10 Physics',
            'created_at' => now()->subDays(1),
        ]);

        // 7. Create a Demo Parent
        $parentUser = User::firstOrCreate(
        ['phone' => '9876543212'],
        [
            'email' => 'parent@demo.com',
            'name' => 'Rajesh Singh',
            'role' => 'parent',
            'status' => 'approved',
            'phone_verified_at' => now(),
        ]
        );

        // 8. Link Parent to Student
        \App\Models\ParentChild::firstOrCreate(
        [
            'parent_id' => $parentUser->id,
            'student_id' => $student->id,
        ],
        [
            'relationship' => 'parent',
            'is_primary' => true,
        ]
        );

        // 9. Create a Demo Agent
        $agentUser = User::firstOrCreate(
        ['phone' => '9876543213'],
        [
            'email' => 'agent@demo.com',
            'name' => 'Suresh Kumar',
            'role' => 'agent',
            'status' => 'approved',
            'phone_verified_at' => now(),
        ]
        );

        Agent::firstOrCreate(
        ['user_id' => $agentUser->id],
        ['referral_code' => 'DEMOAGT123']
        );

        $this->command->info('Demo content seeded successfully!');
        $this->command->info('Teacher Phone: 9876543210 (Use OTP 123456)');
        $this->command->info('Student Phone: 9876543211 (Use OTP 123456)');
        $this->command->info('Parent Phone:  9876543212 (Use OTP 123456)');
        $this->command->info('Agent Phone:   9876543213 (Use OTP 123456)');
    }
}
