import geopy
from geopy.geocoders import Nominatim

# List of addresses to geocode
addresses = [
    "Zac, Plateau des Couleures, Av. De Romans 26000 Valence",
    "Zac De La Mandallaz, 74330 Épagny",
    "Centre Commercial Géant D'aix, Av. d'Aix-les-Bains, 74600 Quintal",
    "27 Rue du Sauvage, 68100 Mulhouse",
    "Centre Commercial Cora, 258 Rue de Belfort, 68200 Mulhouse",
    "2 Rue de la Paix, 68400 Riedisheim",
    "Centre Commercial Cora, 130 Rue de Soultz, 68270 Wittenheim",
    "19 Rue Président Wilson, 42000 Saint-Étienne",
    "Rue des Alliés, 42000 Saint-Étienne",
    "117 Rue Général de Gaulle, 69530 Brignais",
    "58-60 Rue Jean Moulin, 69300 Caluire-et-Cuire",
    "Centre Commercial Auchan, Avenue De La Porte De Lyon, Prte de Lyon, 69570 Dardilly",
    "Ecully Grand Ouest, Centre Commercial Grand Ouest, 69130 Écully",
    "Centre Commercial Carrefour, Av. du Chater, 69340 Francheville",
    "Centre commercial Givors 2 Vallees, Rue de la Paix, 69700 Givors",
    "24 Rue Victor Hugo, 69002 Lyon",
    "46 Rue Juliette Récamier, 69006 Lyon",
    "3 Av. du Plateau, 69009 Lyon",
    "78 Bd de l'Europe, 69310 Pierre-bénite",
    "Centre Commercial Saint Genis 2, 2 Av. Charles de Gaulle, 69230 Saint-Genis-Laval",
    "Centre Commercial Carrefour, 232 Av. Franklin Roosevelt, 69120 Vaulx-en-Velin",
    "Centre Commercial Carrefour, 136 Bd Irène Joliot Curie, 69200 Vénissieux",
    "Le Pré Aubert, Centre Commercial E Leclerc, 89100 Saint-Denis-lès-Sens",
    "90-92 Rue de la République, 89100 Sens"
]

# Initialize geolocator
geolocator = Nominatim(user_agent="geoapiExercises")

# Function to get latitude and longitude
def get_lat_lon(address):
    location = geolocator.geocode(address)
    return (location.latitude, location.longitude) if location else (None, None)

# Get latitude and longitude for each address
lat_lon_list = [get_lat_lon(address) for address in addresses]
print(lat_lon_list)
