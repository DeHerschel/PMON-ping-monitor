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

Auth::routes();
Route::group(['middleware' => 'auth'], function(){
    Route::get('/', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    Route::get('/host', [App\Http\Controllers\HomeController::class, 'hoststab'])->name('host');
    Route::get('/api', [App\Http\Controllers\HomeController::class, 'api'])->name('api');
    // Route::get('/console', [App\Http\Controllers\HomeController::class, 'consoletab'])->name('console');
    Route::get('/configuration', [App\Http\Controllers\HomeController::class, 'conftab'])->name('configuration');
});

/*
Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
*/

