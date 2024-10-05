
function_plot_commune_pourmille <- function(classe_delit,code_commune, code_commune_2)
  {
  nom_commune <- communes_selected %>% filter(DEPCOM == code_commune) %>% pull(NOM_DEPCOM)
  nom_commune_2 <- communes_selected %>% filter(DEPCOM == code_commune_2) %>% pull(NOM_DEPCOM)
 
  data_76_commune <- data_76 %>% filter(CODGEO_2024 == code_commune & classe == classe_delit) %>% mutate(dataset = nom_commune)
  data_76_commune_2 <- data_76 %>% filter(CODGEO_2024 == code_commune_2 & classe == classe_delit) %>% mutate(dataset = nom_commune_2)
  
  data_national_pourmille <- data_national_par_annee_classe %>% filter( classe == classe_delit) %>%  mutate(dataset = 'Moyenne nationale')
  
  data_commune_equivalente <- data_national_par_type_ville %>% filter(type_ville == 'ville moyenne' & classe == classe_delit) %>%  mutate(dataset = 'Ville équivalente à Sotteville-lès-Rouen')
  
  
  all_data <- bind_rows(data_national_pourmille,data_commune_equivalente,data_76_commune,data_76_commune_2)
  all_data <- all_data %>% mutate(annee = as.numeric(paste0('20',annee)))
  
  # Créer le graphique avec Plotly
  plot <- plot_ly() %>%
    
    # Tracer les datasets autres que "nom_commune"
    add_lines(data = all_data[all_data$dataset =='Ville équivalente à Sotteville-lès-Rouen',],
              x = ~annee, y = ~taux, color = ~dataset,
              line = list(width = 1)) %>%
    add_markers(data = all_data[all_data$dataset =='Ville équivalente à Sotteville-lès-Rouen',], 
                x = ~annee, y = ~taux, color = ~dataset, 
                marker = list(size = 6),
                showlegend = FALSE) %>%
    
    # Tracer le dataset de la commune avec une ligne plus épaisse
    add_lines(data = all_data[all_data$dataset == nom_commune,], 
              x = ~annee, y = ~taux, color = ~dataset, 
              line = list(width = 4)) %>%
    add_markers(data = all_data[all_data$dataset == nom_commune,], 
                x = ~annee, y = ~taux, color = ~dataset, 
                marker = list(size = 8),
                showlegend = FALSE) %>%
    add_lines(data = all_data[all_data$dataset == nom_commune_2,], 
              x = ~annee, y = ~taux, color = ~dataset, 
              line = list(width = 4)) %>%
    add_markers(data = all_data[all_data$dataset == nom_commune_2,], 
                x = ~annee, y = ~taux, color = ~dataset, 
                marker = list(size = 8),
                showlegend = FALSE) %>% 
    
    # Titre et labels des axes
    layout(
      title = list(text = paste0(classe_delit, " <br>pour 1000 habitants"),
                   font = list(size = 16), x = 0.5),  # Centrer le titre
      xaxis = list(title = "Années", titlefont = list(size = 16), tickfont = list(size = 14)),
      yaxis = list(title = "Taux (‰)", titlefont = list(size = 16), tickfont = list(size = 14),
                   tickformat = ",.0‰"),  # Ajouter le formatage pour "‰"
      
      # Placer la légende en bas
      legend = list(orientation = "h", x = 0.5, y = -0.2, xanchor = "center", font = list(size = 12)),
      
      # Ajuster les marges pour ne pas couper la légende
      margin = list(l = 50, r = 50, b = 100, t = 50)
    ) %>%
    config(p, responsive = TRUE, displayModeBar = FALSE, scrollZoom = FALSE, doubleClick = FALSE, showTips = TRUE, staticPlot = TRUE)  
  return(plot)
}