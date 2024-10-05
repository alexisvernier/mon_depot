# Fonction serveur
server <- function(input, output, session) {
  
  # Mettre à jour la liste des communes et des classes de délits
  updateSelectizeInput(session, 'commune', 
                       choices = sort(paste0(communes_selected$NOM_DEPCOM, ' (', communes_selected$DEPCOM, ')')), 
                       server = TRUE, selected = 'Sotteville-lès-Rouen (76681)')
  updateSelectizeInput(session, 'commune_2', 
                       choices = sort(paste0(communes_selected$NOM_DEPCOM, ' (', communes_selected$DEPCOM, ')')), 
                       server = TRUE, selected = 'Rouen (76540)')
  updateSelectizeInput(session, 'classe', 
                       choices = c_classe_delit, 
                       server = TRUE,
                       selected = 'Cambriolages de logement')
  
  # Observer les événements quand l'utilisateur sélectionne une classe de délit et une commune
  observeEvent(input$classe, {
    print(input$classe)  # Pour vérifier la classe choisie
  })
  
  observeEvent(input$commune, {
    print(input$commune)  # Pour vérifier la commune choisie
    
    # Trouver le code commune à partir de la sélection
    c_commune <- communes_selected %>% 
      filter(paste0(NOM_DEPCOM, ' (', DEPCOM, ')') == input$commune)
  })

    # Générer le graphique quand les deux inputs sont valides
    output$plot <- renderPlotly({
      req(input$classe !='', input$commune != '', input$commune_2 !='')  # Assurer que les deux inputs sont sélectionnés
      c_commune <- communes_selected %>% 
        filter(paste0(NOM_DEPCOM, ' (', DEPCOM, ')') == input$commune)
      c_commune_2 <- communes_selected %>% 
        filter(paste0(NOM_DEPCOM, ' (', DEPCOM, ')') == input$commune_2)
      function_plot_commune_pourmille(classe_delit = input$classe, code_commune = c_commune$DEPCOM,code_commune_2 = c_commune_2$DEPCOM)}
    )
    
    observeEvent(input$mail, {
      email <- input$mail
      
      # Utiliser une regex pour vérifier le format de l'email
      
      req(input$mail)
      if (!grepl("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email)) {
        showNotification("Veuillez entrer une adresse email valide.", type = "error")
      } else {
        # Code à exécuter si l'email est valide
        showNotification("Adresse email valide!", type = "message")
      }
    })
    
  
      
    observeEvent(input$submit, {
      req(input$prenom != "" && input$nom != "" && input$message != "")
      
      # Insertion des données dans la base de données
      dbExecute(con, "
    INSERT INTO contact_delinquance (prenom, nom, mail, code_postal, message) 
    VALUES ($1, $2, $3, $4, $5)",
                params = list(input$prenom, input$nom, input$mail, input$code_postal, input$message)
      )
      
      # Mise à jour du message de confirmation
      output$confirmation_message <- renderUI({
        tags$div(
          class = "alert alert-success",
          paste("Merci,", input$prenom, input$nom, ", votre message a été envoyé et enregistré !")
        )
      })
    })
    
  
}