<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
Route::get('/stats' , function(){
    return view('stats');
});

Auth::routes();
Route::group(['middleware' => 'auth'], function(){
    Route::get('/', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/hosts', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/console', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/configuration', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
});

/*
Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
*/

