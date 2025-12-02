@extends('layouts.auth')

@section('title')
    Login - Freetunnel Panel
@endsection

@section('content')
    <link rel="stylesheet" href="{{ asset('freetunnel/freetunnel.css') }}">

    <div class="ft-login-bg">
        <div class="ft-login-card">
            <div class="ft-logo-main">
                <img src="/freetunnel/logo.svg" style="width: 260px;" alt="Freetunnel Logo">
            </div>

            <form method="POST" action="{{ route('auth.login') }}">
                @csrf

                <div class="mb-3">
                    <label for="email">Email</label>
                    <input id="email" type="email"
                           class="form-control @error('email') is-invalid @enderror"
                           name="email" value="{{ old('email') }}" required autofocus>
                </div>

                <div class="mb-3">
                    <label for="password">Password</label>
                    <input id="password" type="password"
                           class="form-control @error('password') is-invalid @enderror"
                           name="password" required>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="form-check">
                        <input type="checkbox" name="remember" id="remember"
                               class="form-check-input">
                        <label class="form-check-label" for="remember">
                            Remember me
                        </label>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100">
                    Login ke Freetunnel
                </button>
            </form>

            <div class="ft-login-footer">
                <div>FREE TUNNELING CORP • {{ date('Y') }}</div>
                <div>Powered by Pterodactyl Panel</div>
            </div>
        </div>
    </div>
@endsection