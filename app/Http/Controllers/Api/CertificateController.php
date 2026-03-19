<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Carbon\Carbon;

class CertificateController extends Controller
{
    /**
     * Generate and download a certificate for a student
     */
    public function downloadStudentCertificate(Request $request, $studentId)
    {
        $student = Student::with('user')->findOrFail($studentId);
        $badgeType = $request->query('badge', 'Gold'); // Gold or Silver

        $data = [
            'name' => $student->user->name,
            'reason' => "Awarded the {$badgeType} Badge for exceptional performance in weekly tests.",
            'date' => Carbon::now()->format('d M Y'),
        ];

        $pdf = Pdf::loadView('certificates.default', $data);
        $pdf->setPaper('a4', 'landscape');

        return $pdf->download("Certificate_{$student->user->name}_{$badgeType}.pdf");
    }

    /**
     * Generate and download a certificate for a teacher
     */
    public function downloadTeacherCertificate(Request $request, $teacherId)
    {
        $teacher = Teacher::with('user')->findOrFail($teacherId);

        $data = [
            'name' => $teacher->user->name,
            'reason' => "Awarded the Hero Teacher Badge for maintaining ≥4 star rating and 100% attendance.",
            'date' => Carbon::now()->format('d M Y'),
        ];

        $pdf = Pdf::loadView('certificates.default', $data);
        $pdf->setPaper('a4', 'landscape');

        return $pdf->download("Hero_Teacher_Certificate_{$teacher->user->name}.pdf");
    }

    /**
     * Preview certificate (returns HTML)
     */
    public function previewCertificate(Request $request)
    {
        $data = [
            'name' => $request->query('name', 'John Doe'),
            'reason' => $request->query('reason', 'Excellence in teaching and dedication.'),
            'date' => Carbon::now()->format('d M Y'),
        ];

        return view('certificates.default', $data);
    }
}
