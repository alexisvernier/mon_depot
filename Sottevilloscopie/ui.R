# # Interface utilisateur
# ui <- fluidPage(
#   tags$head(
#     tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
#   ),
#   
#   # Utiliser une div pour le conteneur du titre et du logo
#   div(
#     class = "title-container",
#     img(src = "./static/logo.png", class = "logo", height = "50px"), # Logo avec une taille spécifique
#     div(
#       class = "titre-general",
#       "Cambrioloscopie"  # Le titre à côté du logo
#     )
#   ),
#   # TabPanel UI
#   tabsetPanel(
#     id = "navbar",
#     tabPanel("Accueil",
#     includeMarkdown('www/markdown/Accueil.md')),
#     navbarMenu("Thématiques",
#     tabPanel("Les cambriolages à Sotteville-lès-Rouen",
# 
#     
#     mainPanel(
#       includeMarkdown("www/markdown/main_panel_1.md"),
#       bsCollapse(
#         id = "collapseExample",
#         open = "Dérouler",
#         bsCollapsePanel("Dérouler",
#       selectizeInput("commune", "Choisir une commune :", 
#                      choices = unique(data_76$NOM_DEPCOM),
#                      options = list(
#                        placeholder = 'Commune',
#                        onInitialize = I('function() { this.setValue(""); }')
#                      )),
#       selectizeInput("commune_2", "Choisir une commune supplémentaire :", 
#                      choices = unique(data_76$NOM_DEPCOM),
#                      options = list(
#                        placeholder = 'Commune',
#                        onInitialize = I('function() { this.setValue(""); }')
#                      )),
#       selectInput("classe", "Choisir une catégorie :", choices = c_classe_delit)
#     )),
#     
#     
#       plotlyOutput("plot", height = "500px", width = '100%'),
#       includeMarkdown("www/markdown/main_panel_2.md")
#     )
#   )),
#   # tabPanel("Notre démarche",
#   #          includeMarkdown("www/notre_demarche.md")),
#   # TabPanel pour le formulaire de contact
#   tabPanel("Qui sommes-nous ?",
#            includeMarkdown("www/qui_sommes_nous.md")),
#   tabPanel( "Contact", value = "contact",
#            h3("Contactez-nous"),
#            
#            # Formulaire de contact
#            textInput("prenom", "Prénom", ""),
#            textInput("nom", "Nom"),
#            numericInput("code_postal", "Code postal", value = 0),
#            textInput("mail", "Votre e-mail", ""),
#            textAreaInput("message", "Votre message", "", rows = 5),
#            
#            # Bouton d'envoi
#            actionButton("submit", "Envoyer"),
#            
#            # Zone de confirmation après l'envoi
#            uiOutput("confirmation_message")
#   )
# ))
# 

library(shiny)
library(markdown)  # Assurez-vous d'avoir cette bibliothèque pour inclure les fichiers markdown
library(plotly)    # Si vous utilisez plotly pour les graphiques
library(bsplus)    # Pour bsCollapse

ui <- navbarPage(
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
      ),
  title = div(
    img(src = "./static/logo.png", class = "logo", height = "40px"), 
    "Sottevilloscopie"
  ),
  
  # Onglet Accueil
  tabPanel("Accueil",
           includeMarkdown('www/markdown/Accueil.md')
  ),
  
  # Menu de navigation pour les thématiques
  navbarMenu("Thématiques",
             tabPanel("Les cambriolages à Sotteville-lès-Rouen",
                      mainPanel(
                        includeMarkdown("www/markdown/main_panel_1.md"),
                        bsCollapse(
                          id = "collapseExample",
                          open = "Dérouler",
                          bsCollapsePanel("Dérouler",
                                          selectizeInput("commune", "Choisir une commune :", 
                                                         choices = unique(data_76$NOM_DEPCOM),
                                                         options = list(
                                                           placeholder = 'Commune',
                                                           onInitialize = I('function() { this.setValue(""); }')
                                                         )),
                                          selectizeInput("commune_2", "Choisir une commune supplémentaire :", 
                                                         choices = unique(data_76$NOM_DEPCOM),
                                                         options = list(
                                                           placeholder = 'Commune',
                                                           onInitialize = I('function() { this.setValue(""); }')
                                                         )),
                                          selectInput("classe", "Choisir une catégorie :", choices = c_classe_delit)
                          )
                        ),
                        plotlyOutput("plot", height = "500px", width = '100%'),
                        includeMarkdown("www/markdown/main_panel_2.md")
                      )
             )
  ),
  
  # Onglet Qui sommes-nous ?
  tabPanel("Qui sommes-nous ?", 
           includeMarkdown("www/qui_sommes_nous.md")
  ),
  
  # Onglet Contact
  tabPanel("Contact", 
           h3("Contactez-nous"),
           textInput("prenom", "Prénom", ""),
           textInput("nom", "Nom"),
           numericInput("code_postal", "Code postal", value = 0),
           textInput("mail", "Votre e-mail", ""),
           textAreaInput("message", "Votre message", "", rows = 5),
           actionButton("submit", "Envoyer"),
           uiOutput("confirmation_message")
  )
)

# Reste de votre code pour le serveur...

