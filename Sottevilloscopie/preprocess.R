# library(mapview)
library(webshot2)
library(htmlwidgets)
library(tidyverse)
library(sf)
library(RColorBrewer)
library(leaflet)
# library(arrow)

data <- read_parquet('./data/donnee-comm-data.gouv-parquet-2023-geographie2024-produit-le2024-07-05.parquet')
data_ville_10000hab_et_76 <- data %>% filter(POP > 10000 | substring(CODGEO_2024,1,2)=='76')
data_moyenne_national <- data %>% group_by(annee,classe) %>% summarize(faits = mean(faits, na.rm =  TRUE))
data_moyenne_communale <- data %>% group_by(annee,classe,CODGEO_2024) %>% summarize(faits = mean(faits, na.rm =  TRUE))
data_20_a_30000hab <- data %>% filter(POP >20000 & POP<50000) %>% group_by(annee) %>% summarize(faits = mean(faits, na.rm =  TRUE))
# data_sotteville <- data %>% filter(CODGEO_2024 == '76681')


### Pour le carroyage, fonction qui prend le milieu de chaque classe 

# Fonction pour transformer chaque champ
transformer_classe <- function(df) {
  # Fonction interne pour transformer les valeurs de la colonne
  transform_champ <- function(x) {
    if (grepl("^de", x)) {
      # Cas où ça commence par "de", on extrait les deux nombres et calcule la moyenne
      numbers <- as.numeric(gsub(",", ".", unlist(regmatches(x, gregexpr("[0-9]+,[0-9]+|[0-9]+", x)))))
      return(mean(numbers))
    } else if (grepl("^moins de", x)) {
      # Cas où ça commence par "moins de", on extrait le nombre et fait la moyenne avec 0
      number <- as.numeric(gsub(",", ".", gsub("moins de ", "", x)))
      return(mean(c(0, number)))
    } else if (grepl("^plus de", x)) {
      # Cas où ça commence par "plus de", on extrait juste le nombre
      number <- as.numeric(gsub(",", ".", gsub("plus de ", "", x)))
      return(number)
    } else {
      return(NA) # Valeur NA si aucun des cas n'est satisfait
    }
  }
  
  # Application de la fonction sur la colonne 'classe' et remplacement de la colonne
  df$moyenne_classe <- sapply(df$classe, transform_champ)
  
  # Retourne le dataframe modifié
  return(df)
}

## chargement des carroyages

c_2016 <- st_read('./projet_qgis/2016/cambriolageslogementsechelleinfracommunale.2016.shp') %>% transformer_classe
c_2017 <- st_read('./projet_qgis/2017/cambriolageslogementsechelleinfracommunale.2017.shp') %>% transformer_classe
c_2018 <- st_read('./projet_qgis/2018/cambriolageslogementsechelleinfracommunale.2018.shp') %>% transformer_classe
c_2019 <- st_read('./projet_qgis/2019/cambriolageslogementsechelleinfracommunale.2019.shp') %>% transformer_classe
c_2020 <- st_read('./projet_qgis/2020/cambriolageslogementsechelleinfracommunale.2020.shp') %>% transformer_classe
c_2021 <- st_read('./projet_qgis/2021/cambriolageslogementsechelleinfracommunale.2021.shp') %>% transformer_classe
c_2022 <- st_read('./projet_qgis/2022/cambriolageslogementsechelleinfracommunale.2022.shp') %>% transformer_classe

## 
palette_couleur <- colorNumeric(palette = "viridis", domain = c(0, 20))

m <- carroyage %>% filter(libelle_uu == 'Rouen') %>% mapview(zcol = 'moyenne_classe', col.regions=rev(brewer.pal(9, "RdYlBu")), at = seq(0, 25, by = 5))


fonction_photo <- function(carroyage,nom){
  
  m <- carroyage %>% rename(`Taux pour 1000 habitants` = 'moyenne_classe') %>%  filter(libelle_uu == 'Rouen') %>% mapview(zcol = 'Taux pour 1000 habitants', col.regions=rev(brewer.pal(6, "RdYlGn")), at = seq(0, 20, by = 1))
  
m <- m@map %>% setView(1.092, 49.415, zoom = 13.5)

# Sauvegarder la carte en tant que fichier HTML
html <- paste0(nom,".html")
png <-paste0(nom,".png")
saveWidget(m, file = html)

webshot2::webshot(html, file = paste0('./prod/image/',png))

}
fonction_photo(c_2016,2016)
fonction_photo(c_2017,2017)
fonction_photo(c_2018,2018)
fonction_photo(c_2019,2019)
fonction_photo(c_2020,2020)
fonction_photo(c_2021,2021)
fonction_photo(c_2022,2022)

## comparaison taux de cambriolage

rang_cambriolage <- data_76 %>% filter(classe == 'Cambriolages de logement') %>% mutate(DEPCOM = as.character(CODGEO_2024)) %>% left_join(communes %>% select(DEPCOM,NOM_DEPCOM,EPCI)) 

rang_cambriolage <- rang_cambriolage %>%
  group_by(annee) %>%
  mutate(classement = round(rank(-taux),0),
         annee = as.numeric(paste0('20',annee)))

data_sotteville <- rang_cambriolage %>% filter(DEPCOM == '76681')
ggplot(data_sotteville, aes(x = annee, y = classement)) +
       geom_segment(aes(x = annee, xend = annee, y = 0, yend = classement), color = "grey") +  # Lignes
       geom_point(color = "blue", size = 5) +  # Points ronds
       geom_text(aes(label = paste0(classement, "ème")), 
                                 vjust = -1, hjust =0, size = 5) +  # Ajout des labels avec décalage
       scale_y_reverse() +  # Inverser l'axe des y pour que 1 soit en haut
  scale_x_continuous(breaks = data_sotteville$annee)+
       labs(title = "Classement de Sotteville-lès-Rouen \nen nombre de cambriolages \ndans la Métropole Rouen Normandie",
                       x = "Année",
                       y = "Classement") +
  theme(plot.margin = margin(t = 10, r = 10, b = 10, l = 30)) +
       theme_minimal()
