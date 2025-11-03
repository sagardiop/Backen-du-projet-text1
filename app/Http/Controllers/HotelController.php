<?php

namespace App\Http\Controllers;

use App\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HotelController extends Controller
{
    /**
     * Lister tous les hôtels
     */
    public function index()
    {
        $hotels = Hotel::all();
        return response()->json($hotels);
    }

    /**
     * Créer un nouvel hôtel
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:255',
            'email' => 'nullable|email',
            'prix' => 'nullable|numeric',
            'adresse' => 'nullable|string|max:255',
            'telephone' => 'nullable|string|max:20',
            'devise' => 'nullable|string|max:10',
            'photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('photo')) {
            // Enregistrer l'image dans storage/app/public/hotels
            $validated['photo'] = $request->file('photo')->store('hotels', 'public');
        }

        $hotel = Hotel::create($validated);

        return response()->json([
            'message' => 'Hôtel ajouté avec succès !',
            'hotel' => $hotel
        ], 201);
    }

    /**
     * Afficher un hôtel spécifique
     */
    public function show(Hotel $hotel)
    {
        return response()->json($hotel);
    }

    /**
     * Mettre à jour un hôtel
     */
    public function update(Request $request, Hotel $hotel)
    {
        $validated = $request->validate([
            'nom' => 'sometimes|required|string|max:255',
            'email' => 'nullable|email',
            'prix' => 'nullable|numeric',
            'adresse' => 'nullable|string|max:255',
            'telephone' => 'nullable|string|max:20',
            'devise' => 'nullable|string|max:10',
            'photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('photo')) {
            // Supprimer l'ancienne photo s'il y en a une
            if ($hotel->photo && Storage::disk('public')->exists($hotel->photo)) {
                Storage::disk('public')->delete($hotel->photo);
            }

            // Enregistrer la nouvelle photo
            $validated['photo'] = $request->file('photo')->store('hotels', 'public');
        }

        $hotel->update($validated);

        return response()->json([
            'message' => 'Hôtel mis à jour avec succès !',
            'hotel' => $hotel
        ]);
    }

    /**
     * Supprimer un hôtel (et son image)
     */
    public function destroy(Hotel $hotel)
    {
        // Supprimer la photo associée si elle existe
        if ($hotel->photo && Storage::disk('public')->exists($hotel->photo)) {
            Storage::disk('public')->delete($hotel->photo);
        }

        // Supprimer l'hôtel
        $hotel->delete();

        return response()->json(['message' => 'Hôtel supprimé avec succès.']);
    }

    /**
     * Supprimer TOUS les hôtels et leurs images
     */
 public function deleteAll()
{
    try {
        if (Storage::disk('public')->exists('hotels')) {
            Storage::disk('public')->deleteDirectory('hotels');
        }

        Hotel::truncate();

        return response()->json(['message' => 'Tous les hôtels ont été supprimés avec succès.']);
    } catch (\Exception $e) {
        return response()->json(['message' => 'Erreur lors de la suppression : '.$e->getMessage()], 500);
    }
}
}
