<?php

use App\Http\Controllers\api\AuthController;
use App\Http\Controllers\HotelController;
use Illuminate\Support\Facades\Route;

Route::controller(AuthController::class)->group(function () {
    Route::post('/register', 'register');
    Route::post('/login', 'login');
});
Route::controller(AuthController::class)->group(function () {
    Route::post('/logout', 'logout');
});



Route::delete('hotels/{id}', [HotelController::class, 'destroy']);



Route::apiResource('hotels', HotelController::class);
