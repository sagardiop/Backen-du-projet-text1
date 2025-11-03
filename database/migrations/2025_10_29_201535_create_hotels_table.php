<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('hotels', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
             $table->string('nom');
            $table->string('email')->nullable();
            $table->decimal('prix', 10, 2)->nullable(); 
            $table->string('adresse')->nullable();
            $table->string('telephone')->nullable();
            $table->string('devise')->nullable(); 
            $table->string('photo')->nullable(); 
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hotels');
    }
};
