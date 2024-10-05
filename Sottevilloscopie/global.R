library(tidyverse)
library(ggplot2)
library(plotly)
library(COGiter)
library(bslib)
library(shinyBS)
library(DBI)
library(data.table)
library(RPostgres)
library(markdown)

source('./helpers.R', encoding = "UTF-8")

## Lecture donnée délinquance
data_76 <- fread('./prod/data_76.csv')%>% mutate(taux = round(1000*taux,1))
data_national_par_annee_classe <- fread('./prod/data_national_par_annee_classe.csv') %>% mutate(type_ville = as.character(type_ville), CODGEO_2024 = as.integer(CODGEO_2024)) %>% mutate(taux = round(1000*taux,1))
data_national_par_type_ville <- fread('./prod/data_national_par_type_ville.csv')%>% mutate(CODGEO_2024 = as.integer(CODGEO_2024))%>% mutate(taux = round(1000*taux,1))

## Rempalcer les NA par 0
data_76[is.na(data_76)] <- 0 
data_national_par_annee_classe[is.na(data_national_par_annee_classe)] <- 0 
data_national_par_type_ville[is.na(data_national_par_type_ville)] <- 0 
## Type délit
c_classe_delit <- data_national_par_annee_classe$classe %>% unique() %>% as.vector()

## Communes du 76
communes_selected <- communes %>% filter(DEP == '76')

## Connexion à la base de données
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",  # Nom de la base
  host = "aws-0-eu-west-3.pooler.supabase.com",  # Par exemple 'localhost' ou une IP
  port = 6543,  # Port par défaut de PostgreSQL
  user = "postgres.yfemzhbjlzurihlovkcx",  # Nom d'utilisateur PostgreSQL
  password = "Leradissotteville@01"  # Mot de passe PostgreSQL
)