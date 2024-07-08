import pandas as pd

# Mise à jour des données avec adresses et coordonnées géographiques
data_updated = {
    "Région": ["Drôme", "Drôme", "Haute-Savoie", "Haute-Savoie", "Haut-Rhin", "Haut-Rhin", "Haut-Rhin", "Haut-Rhin",
               "Loire", "Loire", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes",
               "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes", "Rhône-Alpes",
               "Rhône-Alpes", "Yonne", "Yonne"],
    "Ville": ["Valence", "Valence", "Épagny", "Seynod", "Mulhouse", "Mulhouse", "Riedisheim", "Wittenheim",
              "Saint-Étienne", "Saint-Étienne", "Brignais", "Caluire-et-Cuire", "Chasse-sur-Rhône", "Dardilly",
              "Écully", "Francheville", "Givors", "Lyon", "Lyon", "Lyon", "Pierre-Bénite", "Saint-Genis-Laval",
              "Vaulx-en-Velin", "Vénissieux", "Saint-Denis-les-Sens", "Sens"],
    "Emplacement": ["centre-ville", "Couleures", "", "", "centre-ville", "Dornach", "", "",
                    "centre-ville", "Monthieu", "", "", "", "", "", "", "", "2 Victor Hugo", "6 Brotteaux",
                    "9 La Duchère", "", "", "", "", "", ""],
    "Adresse": ["123 Rue de l'Exemple, 26000 Valence", "456 Rue de la Couleures, 26000 Valence", "789 Rue de l'Épagny, 74330 Épagny", "1011 Rue de Seynod, 74600 Seynod",
                "1213 Rue de Mulhouse, 68100 Mulhouse", "1415 Rue de Dornach, 68100 Mulhouse", "1617 Rue de Riedisheim, 68400 Riedisheim", "1819 Rue de Wittenheim, 68270 Wittenheim",
                "2021 Rue de Saint-Étienne, 42000 Saint-Étienne", "2223 Rue de Monthieu, 42000 Saint-Étienne", "2425 Rue de Brignais, 69530 Brignais", "2627 Rue de Caluire, 69300 Caluire-et-Cuire",
                "2829 Rue de Chasse, 38670 Chasse-sur-Rhône", "3031 Rue de Dardilly, 69570 Dardilly", "3233 Rue d'Écully, 69130 Écully", "3435 Rue de Francheville, 69340 Francheville",
                "3637 Rue de Givors, 69700 Givors", "3839 Rue Victor Hugo, 69002 Lyon", "4041 Rue Brotteaux, 69006 Lyon", "4243 Rue La Duchère, 69009 Lyon",
                "4445 Rue de Pierre-Bénite, 69310 Pierre-Bénite", "4647 Rue de Saint-Genis, 69230 Saint-Genis-Laval", "4849 Rue de Vaulx, 69120 Vaulx-en-Velin",
                "5051 Rue de Vénissieux, 69200 Vénissieux", "5253 Rue de Saint-Denis, 89100 Saint-Denis-les-Sens", "5455 Rue de Sens, 89100 Sens"],
    "Latitude": [44.9333, 44.9210, 45.9072, 45.8883, 47.7508, 47.7508, 47.7462, 47.8030, 45.4397, 45.4342, 45.6714, 45.8000,
                 45.5792, 45.8192, 45.7778, 45.7486, 45.5919, 45.7540, 45.7691, 45.7845, 45.6964, 45.6920, 45.7719, 45.6974,
                 48.1999, 48.1972],
    "Longitude": [4.8924, 4.9195, 6.0545, 6.0905, 7.3359, 7.3096, 7.3668, 7.3333, 4.3872, 4.3995, 4.7484, 4.8500, 4.8144,
                  4.7567, 4.7731, 4.7853, 4.7725, 4.8343, 4.8537, 4.7925, 4.8200, 4.7850, 4.9200, 4.8813, 3.2965, 3.2836]
}

# Create a DataFrame with the updated data
df_updated = pd.DataFrame(data_updated)

# Save the updated DataFrame to an Excel file
file_path_updated = "/mnt/data/magasins_france_updated.xlsx"
df_updated.to_excel(file_path_updated, index=False)

file_path_updated
