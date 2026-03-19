<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Tuition Platform</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap');
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-[#F8FAFC] min-h-screen flex items-center justify-center p-6">
    <div class="max-w-md w-full bg-white rounded-[32px] shadow-2xl shadow-indigo-100 p-10 relative overflow-hidden">
        <div class="absolute top-0 right-0 w-32 h-32 bg-indigo-50 rounded-full -mr-16 -mt-16"></div>
        
        <div class="text-center mb-10">
            <div class="w-16 h-16 bg-indigo-600 rounded-2xl flex items-center justify-center text-white text-2xl mx-auto mb-6 shadow-lg shadow-indigo-200">
                <i class="fas fa-shield-halved"></i>
            </div>
            <h1 class="text-2xl font-bold text-slate-900">Admin Portal</h1>
            <p class="text-slate-500 mt-2">Sign in to manage your tuition platform</p>
        </div>

        @if($errors->any())
            <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-xl">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <i class="fas fa-circle-exclamation text-red-500"></i>
                    </div>
                    <div class="ml-3 text-sm text-red-700">
                        {{ $errors->first() }}
                    </div>
                </div>
            </div>
        @endif

        <form action="{{ route('login') }}" method="POST">
            @csrf
            <div class="space-y-6">
                <div>
                    <label class="block text-sm font-semibold text-slate-700 mb-2">Phone Number</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 pl-4 flex items-center text-slate-400">
                            <i class="fas fa-phone"></i>
                        </span>
                        <input type="text" name="phone" required placeholder="+91 98765 43210" 
                            class="w-full pl-11 pr-4 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-semibold text-slate-700 mb-2">Password</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 pl-4 flex items-center text-slate-400">
                            <i class="fas fa-lock"></i>
                        </span>
                        <input type="password" name="password" required placeholder="••••••••" 
                            class="w-full pl-11 pr-4 py-4 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition outline-none">
                    </div>
                </div>

                <div class="flex items-center justify-between">
                    <label class="flex items-center">
                        <input type="checkbox" class="w-4 h-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500">
                        <span class="ml-2 text-sm text-slate-600">Remember me</span>
                    </label>
                    <a href="#" class="text-sm font-semibold text-indigo-600 hover:text-indigo-700">Forgot password?</a>
                </div>

                <button type="submit" class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-4 rounded-2xl transition duration-300 shadow-xl shadow-indigo-100 transform active:scale-[0.98]">
                    Sign In
                </button>
            </div>
        </form>

        <div class="mt-10 pt-10 border-t border-slate-100 text-center">
            <p class="text-sm text-slate-500">Need help? <a href="#" class="text-indigo-600 font-semibold">Contact Support</a></p>
        </div>
    </div>
</body>
</html>
