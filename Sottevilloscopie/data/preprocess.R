library(sf)
library(arrow)

dataset <- open_dataset("./donnees-2023-inter.parquet")

data_national <- dataset %>% collect()

## Data par commune du 76

data_76 <- data_national %>% filter(DEP == '76') %>% mutate(type_ville = case_when(
  POP <2000 ~ 'Commune rurale',
  POP >= 1999 & POP <= 10000 ~ 'Petite ville',
  POP >= 10001 & POP <= 20000 ~ 'Petite ville',
  POP >= 20000 &  POP <= 50000 ~ 'ville moyenne',
  POP >= 50001 & POP <= 100000 ~'Grande ville',
  POP >= 100001 ~'Très grande ville',
  .default = 'erreur')) %>% 
  mutate(taux=as.numeric(faits/POP)) %>% 
  select(CODGEO_2024,annee,classe,taux,POP,type_ville)
## Moyenne nationale

data_national_par_annee_classe<- data_national %>% group_by(annee,classe) %>% summarize(taux = as.numeric(sum(faits, na.rm = TRUE)/sum(POP, na.rm = TRUE)), POP = sum(POP)) %>% ungroup() %>% mutate(type_ville = 'NA', CODGEO_2024 = 'NA')


## Moyenne ville equivalente

df_villes <- data.frame(
  Type_de_ville = c("Communes rurales", "Petites villes", "Villes moyennes", 
                    "Grandes villes", "Très grandes villes", "Métropoles"),
  Population_min = c(0, 2000, 20000, 100000, 200000, 500000),
  Population_max = c(1999, 19999, 99999, 199999, 499999, NA)
)

data_national <- data_national %>% mutate(type_ville = case_when(
  POP <2000 ~ 'Commune rurale',
  POP >= 1999 & POP <= 10000 ~ 'Petite ville',
  POP >= 10001 & POP <= 20000 ~ 'Petite ville',
  POP >= 20000 &  POP <= 50000 ~ 'ville moyenne',
  POP >= 50001 & POP <= 100000 ~'Grande ville',
  POP >= 100001 ~'Très grande ville',
  .default = 'erreur'))
data_national_par_type_ville <- data_national %>% group_by(annee,classe,type_ville) %>% summarize(taux = as.numeric(sum(faits, na.rm = TRUE)/sum(POP, na.rm = TRUE)), POP = sum(POP)) %>% ungroup() %>% mutate( CODGEO_2024 = 'NA')

## Export
data_76 %>% st_write('./prod/data_76.csv')
data_national_par_annee_classe %>% st_write('./prod/data_national_par_annee_classe.csv')
data_national_par_type_ville %>% st_write('./prod/data_national_par_type_ville.csv')

