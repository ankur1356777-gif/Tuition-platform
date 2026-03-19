@extends('layouts.admin')

@section('title', 'Create New User')

@section('content')
<div class="page-header">
    <div>
        <div class="breadcrumb">User Management / Create</div>
        <h1 class="page-title">Create New User</h1>
    </div>
</div>

<div class="card" style="max-width: 800px; margin: 0 auto; padding: 20px;">
    <form action="{{ route('admin.users.store') }}" method="POST">
        @csrf
        
        <div class="row" style="display: flex; flex-wrap: wrap; gap: 20px;">
            <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Role</label>
                <select name="role" id="role_select" class="form-control" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background: white;">
                    <option value="student" {{ request('role') == 'student' ? 'selected' : '' }}>Student</option>
                    <option value="teacher" {{ request('role') == 'teacher' ? 'selected' : '' }}>Teacher</option>
                    <option value="agent" {{ request('role') == 'agent' ? 'selected' : '' }}>Agent</option>
                </select>
            </div>

            <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Name</label>
                <input type="text" name="name" class="form-control" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>
        </div>

        <div class="row" style="display: flex; flex-wrap: wrap; gap: 20px;">
            <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Phone</label>
                <input type="text" name="phone" class="form-control" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>

            <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Email (Optional)</label>
                <input type="email" name="email" class="form-control" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>
        </div>

        <div class="form-group" style="margin-bottom: 16px;">
            <label style="display: block; margin-bottom: 8px; font-weight: 500;">Password</label>
            <input type="password" name="password" class="form-control" required style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
        </div>

        <!-- Teacher Specific Fields -->
        <div id="teacher_fields" style="display: {{ request('role') == 'teacher' ? 'block' : 'none' }}; border-top: 1px solid #eee; padding-top: 20px; margin-top: 20px;">
            <h3 style="margin-bottom: 20px; color: #4f46e5;">Teacher Profile Details</h3>
            
            <div class="row" style="display: flex; flex-wrap: wrap; gap: 20px;">
                <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500;">WhatsApp Number</label>
                    <input type="text" name="whatsapp_number" class="form-control" {{ request('role') == 'teacher' ? 'required' : '' }} style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
                </div>

                <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500;">Experience (Years)</label>
                    <input type="number" name="experience_years" class="form-control" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
                </div>
            </div>

            <div class="row" style="display: flex; flex-wrap: wrap; gap: 20px;">
                <div class="form-group" style="flex: 1; min-width: 300px; margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500;">Select Area/Locality</label>
                    <select name="area_id" id="area_select" class="form-control" {{ request('role') == 'teacher' ? 'required' : '' }} style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background: white;">
                        <option value="">-- Choose Area --</option>
                        @foreach($areas as $area)
                            <option value="{{ $area->id }}">{{ $area->name }}</option>
                        @endforeach
                        <option value="-1">Other (Type manually)</option>
                    </select>
                </div>

                <div class="form-group" id="custom_area_group" style="flex: 1; min-width: 300px; margin-bottom: 16px; display: none;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 500;">Type Custom Area</label>
                    <input type="text" name="custom_area" class="form-control" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Subjects (Comma separated)</label>
                <input type="text" name="subjects" class="form-control" placeholder="Physics, Mathematics, Chemistry" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Classes (Comma separated)</label>
                <input type="text" name="classes" class="form-control" placeholder="Class 9, Class 10, XII" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Qualifications (Comma separated)</label>
                <input type="text" name="qualifications" class="form-control" placeholder="B.Tech, M.Sc, PhD" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 500;">Short Bio</label>
                <textarea name="bio" class="form-control" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;"></textarea>
            </div>
        </div>

        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; background: #4f46e5; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 500; margin-top: 20px;">
            Register & Create User
        </button>
    </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const roleSelect = document.getElementById('role_select');
    const teacherFields = document.getElementById('teacher_fields');
    const areaSelect = document.getElementById('area_select');
    const customAreaGroup = document.getElementById('custom_area_group');

    function toggleTeacherFields() {
        if (roleSelect && teacherFields) {
            if (roleSelect.value === 'teacher') {
                teacherFields.style.display = 'block';
                const wa = document.getElementsByName('whatsapp_number')[0];
                const ai = document.getElementsByName('area_id')[0];
                if(wa) wa.required = true;
                if(ai) ai.required = true;
            } else {
                teacherFields.style.display = 'none';
                const wa = document.getElementsByName('whatsapp_number')[0];
                const ai = document.getElementsByName('area_id')[0];
                if(wa) wa.required = false;
                if(ai) ai.required = false;
            }
        }
    }

    if (roleSelect) {
        roleSelect.addEventListener('change', toggleTeacherFields);
    }
    
    if (areaSelect) {
        areaSelect.addEventListener('change', function() {
            if (this.value === '-1') {
                customAreaGroup.style.display = 'block';
                customAreaGroup.querySelector('input').required = true;
            } else {
                customAreaGroup.style.display = 'none';
                customAreaGroup.querySelector('input').required = false;
            }
        });
    }

    // Initial check
    toggleTeacherFields();
});
</script>
@endsection
