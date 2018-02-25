#Funções em R
#source("D:\\R Analise\\Scripts\\Funcoes_Auttar.R")

Sys.setenv(JAVA_HOME="C:\\Program Files\\Java\\jdk1.8.0_152\\jre\\bin")
library(stringr)
library(ggplot2)
library(plotly)
library(xlsx)
library(rJava)
library(plyr)
library(readxl)
library(excel.link)
library(RODBC)
library(psych)
library(e1071)
library(flexdashboard)
library(shinydashboard)
library(formattable)
library(shiny)
library(DT)
library(plotly)
library(crosstalk)
library(knitr)
library(dygraphs)
library(readr)
library(sqldf)
library(reshape)
library(tidyverse)
library(readxl)

###################################################################
#esta funcao padroniza o nome e criar colunas 
#adicionais para base de dados auttar
###################################################################

cria_coluna_base <- function(base_dados) {
  colnames(base_dados) <- c("CODIGO_EMPRESA", "NOME_EMPRESA", "NUMERO_LOJA",
                              "NOME_LOJA", "CNPJ", "DATA_INCLUSAO", "QTD_TRS",
                              "VLR_TRS", "PRIMEIRA_TRS", "MES_PRIMEIRA_TRS",
                              "ULTIMA_TRS", "MES_ULTIMA_TRS", "ATIVO", "DIAS",
                              "RANGE", "POS_TEF")
  
  base_dados$DIAS_BASE <- c(as.Date(base_dados$ULTIMA_TRS) - as.Date(base_dados$PRIMEIRA_TRS)+1)
  base_dados$DIAS_BASE <- as.numeric(base_dados$DIAS_BASE)
  base_dados$CODIGO_EMPRESA <- str_pad(base_dados$CODIGO_EMPRESA, 5, pad = "0")
  base_dados$NUMERO_LOJA <- str_pad(base_dados$NUMERO_LOJA, 4, pad = "0")
  base_dados$ID_LOJA <- c(paste(base_dados$CODIGO_EMPRESA,base_dados$NUMERO_LOJA, sep = "") )
  base_dados$ANO_PRIMEIRA_TRS = as.numeric(format(base_dados$PRIMEIRA_TRS, "%Y"))
  base_dados$ANO_ULTIMA_TRS = as.numeric(format(base_dados$ULTIMA_TRS, "%Y"))
  base_dados$VLR_TRS <- as.numeric(base_dados$VLR_TRS)
  base_dados$MEDIA_TRS_DIA <- c(base_dados$QTD_TRS/ as.integer(base_dados$DIAS_BASE))
  base_dados$MEDIA_VLR_DIA <- c(base_dados$VLR_TRS/ as.integer(base_dados$DIAS_BASE))
  base_dados$MEDIA_TRS_DIA <- round(base_dados$MEDIA_TRS_DIA, 2)
  base_dados$MEDIA_VLR_DIA <- round(base_dados$MEDIA_VLR_DIA, 2)
  base_dados$MES_PRIMEIRA_TRS <- format(base_dados$PRIMEIRA_TRS, "%b, %Y")
  base_dados$MES_ULTIMA_TRS <- format(base_dados$ULTIMA_TRS, "%b, %Y")
  
  return(base_dados)
}
###################################################################
#base_dados_1 é o índice(use a coluna índice), 
#a base_dados_2 é onde vai procurar o valor
###################################################################
procv_excel <- function(base_dados_1, base_dados_2) {
resultado <- with(base_dados_2,
     base_dados_2$QTD_TRS[match(base_dados_1$ID_LOJA,
                                base_dados_2$ID_LOJA)])
  return(resultado)}

###################################################################
#calcular moda
###################################################################
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
#######################################################################
#segmentar por dias de transação na base. Deve normalizar base antes.
#######################################################################
analisar_dias_base <- function(base_ativa, ano_base){
  
    
  data_inativo_2017 <- subset(base_ativa, NUMERO_LOJA  != ""
                              & ANO_ULTIMA_TRS >= ano_base)
  

  # CRIAR DADA FRAME VAZIOS

  
  
  resultado_inativo_dias <- data.frame(Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer(),
                                       Ints=integer())
  
  
  
  colnames(resultado_inativo_dias) <- c("DIA",
                                        "QTDA_INATIVO",
                                        "QTDA_ATIVO",
                                        "TOTAL_LJ" , 
                                        
                                        "MEDIAN_TRS_INAT",
                                        "MEDIAN_TRS_ATIV",
                                        
                                        
                                        "MEAN_TRS_INAT",
                                        "MEAN_TRS_ATIV",
                                        
                                        "MODE_TRS_INAT",
                                        "MODE_TRS_ATIV",
                                        
                                        "MEDIAN_VLR_INAT",
                                        "MEDIAN_VLR_ATIV",
                                        
                                        "MEAN_VLR_INAT",
                                        "MEAN_VLR_ATIV",
                                        
                                        "MODE_VLR_INAT",
                                        "MODE_VLR_ATIV",
                                        
                                        "PCT_INAT_X_ATIV",
                                        
                                        "PCT_ATIV_X_INAT",
                                        "PCT_INAT_X_TOT_INAT",
                                        "PCT_INAT_X_TOT_ATIV",
                                        "PCT_INAT_X_TOT_LJ")
  
  
  

  # ADD DADOS INICIAIS

  
  BASE_COUNT <- filter(data_inativo_2017, DIAS_BASE <= 1 )
  TEMP <- table(BASE_COUNT$ATIVO)
  
  CAL_INAT <- filter(data_inativo_2017, DIAS_BASE <= 1, ATIVO == 0)
  CAL_ATIV <- filter(data_inativo_2017, DIAS_BASE <= 1, ATIVO == 1)
  
  
  CMEDIAN_TRS_INAT <- median(CAL_INAT$MEDIA_TRS_DIA)
  CMEDIAN_TRS_ATIV <- median(CAL_ATIV$MEDIA_TRS_DIA)
  CMEAN_TRS_INAT <- mean(CAL_INAT$MEDIA_TRS_DIA)
  CMEAN_TRS_ATIV <- mean(CAL_ATIV$MEDIA_TRS_DIA)
  CMODA_TRS_INAT <- Mode(CAL_INAT$MEDIA_TRS_DIA)
  CMODA_TRS_ATIV <- Mode(CAL_ATIV$MEDIA_TRS_DIA)
  
  
  
  CMEDIAN_VLR_INAT <- median(CAL_INAT$MEDIA_VLR_DIA)
  CMEDIAN_VLR_ATIV <- median(CAL_ATIV$MEDIA_VLR_DIA)
  CMEAN_VLR_INAT <- mean(CAL_INAT$MEDIA_VLR_DIA)
  CMEAN_VLR_ATIV <- mean(CAL_ATIV$MEDIA_VLR_DIA)
  CMODA_VLR_INAT <- Mode(CAL_INAT$MEDIA_VLR_DIA)
  CMODA_VLR_ATIV <- Mode(CAL_ATIV$MEDIA_VLR_DIA)
  
  
  PCT <- prop.table(TEMP)*100
  TOTAL_LOJA <- sum(TEMP)
  TEMP <- as.factor(TEMP)
  
  
  resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                  data.frame(DIA = 1 ,
                                             QTDA_INATIVO = TEMP[1] ,
                                             QTDA_ATIVO =TEMP[2],
                                             TOTAL_LJ = TOTAL_LOJA,
                                             
                                             MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                             MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                             
                                             MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                             MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                             
                                             MODE_TRS_INAT = CMODA_TRS_INAT,
                                             MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                             
                                             MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                             MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                             
                                             MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                             MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                             
                                             MODE_VLR_INAT = CMODA_VLR_INAT,
                                             MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                             
                                             PCT_INAT_X_ATIV = PCT[1],
                                             PCT_ATIV_X_INAT = PCT[2],                        
                                             PCT_INAT_X_TOT_INAT = 0))
  
  
  BASE_COUNT <- filter(data_inativo_2017, DIAS_BASE >= 2 & DIAS_BASE <=7)
  TEMP <- table(BASE_COUNT$ATIVO)
  
  CAL_INAT <- filter(data_inativo_2017, DIAS_BASE >= 2 & DIAS_BASE <=7 & ATIVO == 0)
  CAL_ATIV <- filter(data_inativo_2017, DIAS_BASE >= 2 & DIAS_BASE <=7 & ATIVO == 1)
  
  
  CMEDIAN_TRS_INAT <- median(CAL_INAT$MEDIA_TRS_DIA)
  CMEDIAN_TRS_ATIV <- median(CAL_ATIV$MEDIA_TRS_DIA)
  CMEAN_TRS_INAT <- mean(CAL_INAT$MEDIA_TRS_DIA)
  CMEAN_TRS_ATIV <- mean(CAL_ATIV$MEDIA_TRS_DIA)
  CMODA_TRS_INAT <- Mode(CAL_INAT$MEDIA_TRS_DIA)
  CMODA_TRS_ATIV <- Mode(CAL_ATIV$MEDIA_TRS_DIA)
  
  
  
  CMEDIAN_VLR_INAT <- median(CAL_INAT$MEDIA_VLR_DIA)
  CMEDIAN_VLR_ATIV <- median(CAL_ATIV$MEDIA_VLR_DIA)
  CMEAN_VLR_INAT <- mean(CAL_INAT$MEDIA_VLR_DIA)
  CMEAN_VLR_ATIV <- mean(CAL_ATIV$MEDIA_VLR_DIA)
  CMODA_VLR_INAT <- Mode(CAL_INAT$MEDIA_VLR_DIA)
  CMODA_VLR_ATIV <- Mode(CAL_ATIV$MEDIA_VLR_DIA)
  
  
  PCT <- prop.table(TEMP)*100
  TOTAL_LOJA <- sum(TEMP)
  TEMP <- as.factor(TEMP)
  
  
  resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                  data.frame(DIA = 7 ,
                                             QTDA_INATIVO = TEMP[1] ,
                                             QTDA_ATIVO =TEMP[2],
                                             TOTAL_LJ = TOTAL_LOJA,
                                             
                                             MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                             MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                             
                                             MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                             MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                             
                                             MODE_TRS_INAT = CMODA_TRS_INAT,
                                             MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                             
                                             MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                             MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                             
                                             MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                             MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                             
                                             MODE_VLR_INAT = CMODA_VLR_INAT,
                                             MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                             
                                             PCT_INAT_X_ATIV = PCT[1],
                                             PCT_ATIV_X_INAT = PCT[2],                        
                                             PCT_INAT_X_TOT_INAT = 0))
  
  
  
  
  BASE_COUNT <- filter(data_inativo_2017, DIAS_BASE <= 15 & DIAS_BASE >= 4)
  TEMP <- table(BASE_COUNT$ATIVO)
  
  
  CAL_INAT <- filter(data_inativo_2017, DIAS_BASE <= 15 & DIAS_BASE >= 4 & ATIVO == 0)
  CAL_ATIV <- filter(data_inativo_2017, DIAS_BASE <= 15 & DIAS_BASE >= 4 & ATIVO == 1)
  
  CMEDIAN_TRS_INAT <- median(CAL_INAT$MEDIA_TRS_DIA)
  CMEDIAN_TRS_ATIV <- median(CAL_ATIV$MEDIA_TRS_DIA)
  CMEAN_TRS_INAT <- mean(CAL_INAT$MEDIA_TRS_DIA)
  CMEAN_TRS_ATIV <- mean(CAL_ATIV$MEDIA_TRS_DIA)
  CMODA_TRS_INAT <- Mode(CAL_INAT$MEDIA_TRS_DIA)
  CMODA_TRS_ATIV <- Mode(CAL_ATIV$MEDIA_TRS_DIA)
  
  
  
  CMEDIAN_VLR_INAT <- median(CAL_INAT$MEDIA_VLR_DIA)
  CMEDIAN_VLR_ATIV <- median(CAL_ATIV$MEDIA_VLR_DIA)
  CMEAN_VLR_INAT <- mean(CAL_INAT$MEDIA_VLR_DIA)
  CMEAN_VLR_ATIV <- mean(CAL_ATIV$MEDIA_VLR_DIA)
  CMODA_VLR_INAT <- Mode(CAL_INAT$MEDIA_VLR_DIA)
  CMODA_VLR_ATIV <- Mode(CAL_ATIV$MEDIA_VLR_DIA)
  
  
  PCT <- prop.table(TEMP)*100
  TOTAL_LOJA <- sum(TEMP)
  TEMP <- as.factor(TEMP)
  
  
  
  resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                  data.frame(DIA = 15 ,
                                             QTDA_INATIVO = TEMP[1] ,
                                             QTDA_ATIVO =TEMP[2],
                                             TOTAL_LJ = TOTAL_LOJA,
                                             
                                             MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                             MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                             
                                             MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                             MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                             
                                             MODE_TRS_INAT = CMODA_TRS_INAT,
                                             MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                             
                                             MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                             MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                             
                                             MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                             MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                             
                                             MODE_VLR_INAT = CMODA_VLR_INAT,
                                             MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                             
                                             PCT_INAT_X_ATIV = PCT[1],
                                             PCT_ATIV_X_INAT = PCT[2],                        
                                             PCT_INAT_X_TOT_INAT = 0))
  
  
  BASE_COUNT <- filter(data_inativo_2017, DIAS_BASE <= 30 & DIAS_BASE >= 16)
  TEMP <- table(BASE_COUNT$ATIVO)
  
  
  CAL_INAT <- filter(data_inativo_2017, DIAS_BASE <= 30 & DIAS_BASE >= 16 & ATIVO == 0)
  CAL_ATIV <- filter(data_inativo_2017, DIAS_BASE <= 30 & DIAS_BASE >= 16 & ATIVO == 1)
  
  CMEDIAN_TRS_INAT <- median(CAL_INAT$MEDIA_TRS_DIA)
  CMEDIAN_TRS_ATIV <- median(CAL_ATIV$MEDIA_TRS_DIA)
  CMEAN_TRS_INAT <- mean(CAL_INAT$MEDIA_TRS_DIA)
  CMEAN_TRS_ATIV <- mean(CAL_ATIV$MEDIA_TRS_DIA)
  CMODA_TRS_INAT <- Mode(CAL_INAT$MEDIA_TRS_DIA)
  CMODA_TRS_ATIV <- Mode(CAL_ATIV$MEDIA_TRS_DIA)
  
  
  
  CMEDIAN_VLR_INAT <- median(CAL_INAT$MEDIA_VLR_DIA)
  CMEDIAN_VLR_ATIV <- median(CAL_ATIV$MEDIA_VLR_DIA)
  CMEAN_VLR_INAT <- mean(CAL_INAT$MEDIA_VLR_DIA)
  CMEAN_VLR_ATIV <- mean(CAL_ATIV$MEDIA_VLR_DIA)
  CMODA_VLR_INAT <- Mode(CAL_INAT$MEDIA_VLR_DIA)
  CMODA_VLR_ATIV <- Mode(CAL_ATIV$MEDIA_VLR_DIA)
  
  
  PCT <- prop.table(TEMP)*100
  TOTAL_LOJA <- sum(TEMP)
  TEMP <-  as.factor(TEMP)
  
  
  
  resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                  data.frame(DIA = 30 ,
                                             QTDA_INATIVO = TEMP[1] ,
                                             QTDA_ATIVO =TEMP[2],
                                             TOTAL_LJ = TOTAL_LOJA,
                                             
                                             MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                             MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                             
                                             MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                             MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                             
                                             MODE_TRS_INAT = CMODA_TRS_INAT,
                                             MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                             
                                             MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                             MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                             
                                             MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                             MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                             
                                             MODE_VLR_INAT = CMODA_VLR_INAT,
                                             MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                             
                                             PCT_INAT_X_ATIV = PCT[1],
                                             PCT_ATIV_X_INAT = PCT[2],                        
                                             PCT_INAT_X_TOT_INAT = 0))
  

  # ADD DADOS EM LOOP

  
  
  
  x = 60
  while(x < 3000){
    BASE_COUNT <- filter(data_inativo_2017, DIAS_BASE <= x & DIAS_BASE >= x-29)
    TEMP <- table(BASE_COUNT$ATIVO)
    
    
    CAL_INAT <- filter(data_inativo_2017, DIAS_BASE <= x & DIAS_BASE >= x-29 & ATIVO == 0)
    CAL_ATIV <- filter(data_inativo_2017, DIAS_BASE <= x & DIAS_BASE >= x-29 & ATIVO == 1)
    
    CMEDIAN_TRS_INAT <- median(CAL_INAT$MEDIA_TRS_DIA)
    CMEDIAN_TRS_ATIV <- median(CAL_ATIV$MEDIA_TRS_DIA)
    CMEAN_TRS_INAT <- mean(CAL_INAT$MEDIA_TRS_DIA)
    CMEAN_TRS_ATIV <- mean(CAL_ATIV$MEDIA_TRS_DIA)
    CMODA_TRS_INAT <- Mode(CAL_INAT$MEDIA_TRS_DIA)
    CMODA_TRS_ATIV <- Mode(CAL_ATIV$MEDIA_TRS_DIA)
    
    
    
    
    CMEDIAN_VLR_INAT <- median(CAL_INAT$MEDIA_VLR_DIA)
    CMEDIAN_VLR_ATIV <- median(CAL_ATIV$MEDIA_VLR_DIA)
    CMEAN_VLR_INAT <- mean(CAL_INAT$MEDIA_VLR_DIA)
    CMEAN_VLR_ATIV <- mean(CAL_ATIV$MEDIA_VLR_DIA)
    CMODA_VLR_INAT <- Mode(CAL_INAT$MEDIA_VLR_DIA)
    CMODA_VLR_ATIV <- Mode(CAL_ATIV$MEDIA_VLR_DIA)
    
    
    PCT <- prop.table(TEMP)*100
    TOTAL_LOJA <- sum(TEMP)
    TEMP <- as.factor(TEMP)
    TEMP <- as.data.frame(TEMP)
    TEMP <- t(TEMP)
    indx <- grepl(0, colnames(TEMP))
    
    if (length(indx) == 0)
    {x=x+30}
    else if  (indx[1] == TRUE)
    {resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                     data.frame(DIA = x ,
                                                QTDA_INATIVO = TEMP[1] ,
                                                QTDA_ATIVO =TEMP[2],
                                                TOTAL_LJ = TOTAL_LOJA,
                                                
                                                MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                                MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                                
                                                MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                                MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                                
                                                MODE_TRS_INAT = CMODA_TRS_INAT,
                                                MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                                
                                                MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                                MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                                
                                                MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                                MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                                
                                                MODE_VLR_INAT = CMODA_VLR_INAT,
                                                MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                                
                                                
                                                PCT_INAT_X_ATIV = PCT[1],
                                                PCT_ATIV_X_INAT = PCT[2],
                                                PCT_INAT_X_TOT_INAT = 0))
    
    x=x+30}
    
    else {resultado_inativo_dias <- rbind(resultado_inativo_dias, 
                                          data.frame(DIA = x ,
                                                     QTDA_INATIVO = 0,
                                                     QTDA_ATIVO =TEMP[1],
                                                     TOTAL_LJ = TOTAL_LOJA,
                                                     
                                                     MEDIAN_TRS_INAT = CMEDIAN_TRS_INAT,
                                                     MEDIAN_TRS_ATIV = CMEDIAN_TRS_ATIV,
                                                     
                                                     MEAN_TRS_INAT = CMEAN_TRS_INAT,
                                                     MEAN_TRS_ATIV = CMEAN_TRS_ATIV,
                                                     
                                                     MODE_TRS_INAT = CMODA_TRS_INAT,
                                                     MODE_TRS_ATIV = CMODA_TRS_ATIV,
                                                     
                                                     MEDIAN_VLR_INAT = CMEDIAN_VLR_INAT,
                                                     MEDIAN_VLR_ATIV = CMEDIAN_VLR_ATIV,
                                                     
                                                     MEAN_VLR_INAT = CMEAN_VLR_INAT,
                                                     MEAN_VLR_ATIV = CMEAN_VLR_ATIV,
                                                     
                                                     MODE_VLR_INAT = CMODA_VLR_INAT,
                                                     MODE_VLR_ATIV = CMODA_VLR_ATIV,
                                                     
                                                     PCT_INAT_X_ATIV = 0,
                                                     PCT_ATIV_X_INAT = PCT[1],
                                                     PCT_INAT_X_TOT_INAT = 0))
    
    x=x+30}
  }
  

  #transforma colunas em tipo númerico

  
  
  
  
  resultado_inativo_dias$QTDA_INATIVO <- as.character(resultado_inativo_dias$QTDA_INATIVO)
  resultado_inativo_dias$QTDA_INATIVO <- as.numeric(resultado_inativo_dias$QTDA_INATIVO)
  
  resultado_inativo_dias$QTDA_ATIVO <- as.character(resultado_inativo_dias$QTDA_ATIVO)
  resultado_inativo_dias$QTDA_ATIVO <- as.numeric(resultado_inativo_dias$QTDA_ATIVO)
  
  resultado_inativo_dias$TOTAL_LJ <- as.character(resultado_inativo_dias$TOTAL_LJ)
  resultado_inativo_dias$TOTAL_LJ <- as.numeric(resultado_inativo_dias$TOTAL_LJ)
  

  #calcula porcentangem de inativo em relação ao total de inativos

  resultado_inativo_dias[is.na(resultado_inativo_dias)] <- 0
  
  TOTAL = NULL
  x = 1
  while(x < length(resultado_inativo_dias$QTDA_INATIVO)+1){
    TOTAL <-  rbind(TOTAL, resultado_inativo_dias[x,2]/sum(resultado_inativo_dias$QTDA_INATIVO)*100)
    x=x+1
  }
  
  resultado_inativo_dias$PCT_INAT_X_TOT_INAT <- TOTAL
  

  #calcula porcentangem de inativo em relação ao total de ativos

  
  TOTAL = NULL
  x = 1
  while(x < length(resultado_inativo_dias$QTDA_ATIVO)+1){
    
    TOTAL <-  rbind(TOTAL,
                    resultado_inativo_dias[x,2]/sum(resultado_inativo_dias$QTDA_ATIVO)*100)
    x=x+1
  }
  resultado_inativo_dias[is.na(resultado_inativo_dias)] <- 0
  resultado_inativo_dias$PCT_INAT_X_TOT_ATIV <- TOTAL
  

  #calcula porcentangem de inativo em relação ao total de ativos

  
  TOTAL = NULL
  x = 1
  while(x < length(resultado_inativo_dias$TOTAL_LJ)+1){
    TOTAL <-  rbind(TOTAL,
                    resultado_inativo_dias[x,2]/sum(resultado_inativo_dias$TOTAL_LJ)*100)
    x=x+1
  }
  
  resultado_inativo_dias$PCT_INAT_X_TOT_LJ <- TOTAL
  resultado_inativo_dias[is.na(resultado_inativo_dias)] <- 0
  
  x=1
  while(x < 22){
    if (x == 1 | x == 2 |  x == 3 |  x == 4){
      x=x+1}
    else {
      resultado_inativo_dias[,x:x] <- as.numeric(resultado_inativo_dias[,x:x])
      resultado_inativo_dias[,x:x] <- formattable(resultado_inativo_dias[,x:x], digits = 2, format = "f")}
    x=x+1}
  
  return(resultado_inativo_dias)
}


###################################################################
#mostrar média de transação dias entre duas bases
###################################################################
segmentar_media_trs <- function(BUSCA_BASE_5, BUSCA_BASE_6){

  BUSCA_BASE_5<- cria_coluna_base(BUSCA_BASE_5)
  BUSCA_BASE_6<- cria_coluna_base(BUSCA_BASE_6)
  
BUSCA_BASE_5$QTD_TRS_2 <- procv_excel(BUSCA_BASE_5,BUSCA_BASE_6)
BUSCA_BASE_5$QTD_TRS_2 <- BUSCA_BASE_5$QTD_TRS_2 - BUSCA_BASE_5$QTD_TRS

if ((
  as.numeric(as.Date(max(BUSCA_BASE_6$ULTIMA_TRS)) 
             - as.Date(max(BUSCA_BASE_5$ULTIMA_TRS)))) == 1){
  BUSCA_BASE_5$MEDIA_TRS_DIA_2 <- BUSCA_BASE_5$QTD_TRS_2 
}else {BUSCA_BASE_5$MEDIA_TRS_DIA_2 <- BUSCA_BASE_5$QTD_TRS_2/(
  as.numeric(as.Date(max(BUSCA_BASE_6$ULTIMA_TRS)) 
             - as.Date(max(BUSCA_BASE_5$ULTIMA_TRS))))
}


BUSCA_BASE_5$SEGMENTO = "NA"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 < 1)] = "0-1"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 >= 1 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 2)] = "1-2"

BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 2 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 10)] = "2-10"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 10 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 20)] = "10-20"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 20 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 30)] = "20-30"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 30 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 60)] = "30-60"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 60 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 100)] = "60-100"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 100 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 200)] = "100-200"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 200 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 500)] = "200-500"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 500 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 1000)] = "500-1000"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 1000 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 2000)] = "1000-2000"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 2000 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 5000)] = "2000-5000"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 5000 & 
                              BUSCA_BASE_5$MEDIA_TRS_DIA_2 <= 10000)] = "5000-10000"
BUSCA_BASE_5$SEGMENTO[which(BUSCA_BASE_5$MEDIA_TRS_DIA_2 > 10000)] = "+10000"




BUSCA_BASE_5$SEGMENTO = factor(x = BUSCA_BASE_5$SEGMENTO, 
                               levels = c("0-1", "1-2","2-10",
                                          "10-20", "20-30", "30-60","60-100",
                                          "100-200", "200-500", "500-1000",
                                          "1000-2000","2000-5000","5000-10000",
                                          "+10000"))
BASE_DIA <- filter(BUSCA_BASE_5, DIAS <= 1 & ATIVO == 1 & MEDIA_TRS_DIA_2 > 0)


r = aggregate(x = BASE_DIA$ATIVO, by = list(BASE_DIA$SEGMENTO), sum)
r$perc <- round(prop.table(r$x)*100, 2)


qda_trs <- as.vector(tapply(c(BASE_DIA$MEDIA_TRS_DIA_2), BASE_DIA$SEGMENTO, sum))
r$qda_trs <- qda_trs[!is.na(qda_trs)]
r$perc_trs <- round(prop.table(r$qda_trs)*100, 2)

colnames(r) <- c("GRUPOS", "LOJAS","PERC_LOJA", "QTD_TRS", "PERC_TRS")

return(r)}


############################################
#
############################################

normalizar_base <- function(BUSCA_BASE_6){

BUSCA_BASE_6 = BUSCA_BASE_6[-1,]
BUSCA_BASE_6 <- BUSCA_BASE_6[-nrow(BUSCA_BASE_6),] 

names(BUSCA_BASE_6) <- lapply(BUSCA_BASE_6[1, ], as.character)
BUSCA_BASE_6 = BUSCA_BASE_6[-1,]


BUSCA_BASE_6$DATA1 <- as.numeric(BUSCA_BASE_6$`Dt Ultima Trs`)
BUSCA_BASE_6$`Dt Ultima Trs` <- as.Date(BUSCA_BASE_6$`Dt Ultima Trs`, "%m/%d/%Y")

BUSCA_BASE_6$DATA1 <- as.Date(BUSCA_BASE_6$DATA1, origin = "1899-12-30")
BUSCA_BASE_6$DATA1 <- as.character(BUSCA_BASE_6$DATA1)
BUSCA_BASE_6$DATA1[is.na(BUSCA_BASE_6$DATA1)] <- 0
BUSCA_BASE_6$`Dt Ultima Trs` <- as.character(BUSCA_BASE_6$`Dt Ultima Trs`)


x=1
while(x < length(BUSCA_BASE_6$`Dt Ultima Trs`)+1){
  if(BUSCA_BASE_6$DATA1[x] != 0){
    BUSCA_BASE_6$`Dt Ultima Trs`[x] <- BUSCA_BASE_6$DATA1[x]}
  x=x+1
}


BUSCA_BASE_6$DATA2 <- as.numeric(BUSCA_BASE_6$`Dt Primeira Trs`)
BUSCA_BASE_6$`Dt Primeira Trs` <- as.Date(BUSCA_BASE_6$`Dt Primeira Trs`, "%m/%d/%Y")

BUSCA_BASE_6$DATA2 <- as.Date(BUSCA_BASE_6$DATA2, origin = "1899-12-30")
BUSCA_BASE_6$DATA2 <- as.character(BUSCA_BASE_6$DATA2)
BUSCA_BASE_6$DATA2[is.na(BUSCA_BASE_6$DATA2)] <- 0
BUSCA_BASE_6$`Dt Primeira Trs` <- as.character(BUSCA_BASE_6$`Dt Primeira Trs`)

x=1
while(x < length(BUSCA_BASE_6$`Dt Primeira Trs`)+1){
  if(BUSCA_BASE_6$DATA2[x] != 0){
    BUSCA_BASE_6$`Dt Primeira Trs`[x] <- BUSCA_BASE_6$DATA2[x]}
  x=x+1
}



BUSCA_BASE_6$`Codigo Empresa` <- str_pad(BUSCA_BASE_6$`Codigo Empresa`, 5, pad = "0")
BUSCA_BASE_6$`Numero Loja` <- str_pad(BUSCA_BASE_6$`Numero Loja`, 4, pad = "0")

BUSCA_BASE_6 <- BUSCA_BASE_6[,-(17:18)] 

colnames(BUSCA_BASE_6) <- c("CODIGO_EMPRESA", "NOME_EMPRESA", "NUMERO_LOJA",
                            "NOME_LOJA", "CNPJ", "DATA_INCLUSAO", "QTD_TRS",
                            "VLR_TRS", "PRIMEIRA_TRS", "MES_PRIMEIRA_TRS",
                            "ULTIMA_TRS", "MES_ULTIMA_TRS", "ATIVO", "DIAS",
                            "RANGE", "POS_TEF")


BUSCA_BASE_6$DATA_INCLUSAO <- as.numeric(BUSCA_BASE_6$DATA_INCLUSAO)
BUSCA_BASE_6$DATA_INCLUSAO <- as.Date(BUSCA_BASE_6$DATA_INCLUSAO, origin = "1899-12-30")
BUSCA_BASE_6$DATA_INCLUSAO <- as.character(BUSCA_BASE_6$DATA_INCLUSAO)
BUSCA_BASE_6$DATA_INCLUSAO[is.na(BUSCA_BASE_6$DATA_INCLUSAO)] <- 0
BUSCA_BASE_6$DATA_INCLUSAO <- as.character(BUSCA_BASE_6$DATA_INCLUSAO)


BUSCA_BASE_6$PRIMEIRA_TRS <- as.Date(BUSCA_BASE_6$PRIMEIRA_TRS)
BUSCA_BASE_6$ULTIMA_TRS <- as.Date(BUSCA_BASE_6$ULTIMA_TRS)
BUSCA_BASE_6$DIAS_BASE <- c(as.Date(BUSCA_BASE_6$ULTIMA_TRS) - as.Date(BUSCA_BASE_6$PRIMEIRA_TRS)+1)
BUSCA_BASE_6$DIAS_BASE <- as.numeric(BUSCA_BASE_6$DIAS_BASE)

BUSCA_BASE_6$DAY_TO_ATV <- c(as.Date(BUSCA_BASE_6$PRIMEIRA_TRS) - as.Date(BUSCA_BASE_6$DATA_INCLUSAO)+1)
BUSCA_BASE_6$DAY_TO_ATV <- as.numeric(BUSCA_BASE_6$DAY_TO_ATV)



BUSCA_BASE_6$ID_LOJA <- c(paste(BUSCA_BASE_6$CODIGO_EMPRESA,BUSCA_BASE_6$NUMERO_LOJA, sep = "") )
BUSCA_BASE_6$ANO_PRIMEIRA_TRS <- as.numeric(format(BUSCA_BASE_6$PRIMEIRA_TRS, "%Y"))
BUSCA_BASE_6$ANO_ULTIMA_TRS <- as.numeric(format(BUSCA_BASE_6$ULTIMA_TRS, "%Y"))
BUSCA_BASE_6$VLR_TRS <- as.numeric(BUSCA_BASE_6$VLR_TRS)
BUSCA_BASE_6$MEDIA_TRS_DIA <- c(as.numeric(BUSCA_BASE_6$QTD_TRS)/ as.numeric(BUSCA_BASE_6$DIAS_BASE))
BUSCA_BASE_6$MEDIA_VLR_DIA <- c(BUSCA_BASE_6$VLR_TRS/ as.integer(BUSCA_BASE_6$DIAS_BASE))


x=1
while(x < length(BUSCA_BASE_6$DAY_TO_ATV)+1){
  if(BUSCA_BASE_6$DAY_TO_ATV[x] < 0){
    BUSCA_BASE_6$DAY_TO_ATV[x] <- 0}
  x=x+1
}

BUSCA_BASE_6$DAY_TO_ATV <- as.numeric(BUSCA_BASE_6$DAY_TO_ATV)
BUSCA_BASE_6$DIAS_BASE <- as.numeric(BUSCA_BASE_6$DIAS_BASE)
BUSCA_BASE_6$DIAS <- as.numeric(BUSCA_BASE_6$DIAS)
BUSCA_BASE_6$RANGE <- as.numeric(BUSCA_BASE_6$RANGE)
BUSCA_BASE_6$ATIVO  <- as.numeric(BUSCA_BASE_6$ATIVO)



BUSCA_BASE_6$MES_PRIMEIRA_TRS <- format(BUSCA_BASE_6$PRIMEIRA_TRS, "%b, %Y")
BUSCA_BASE_6$MES_ULTIMA_TRS <- format(BUSCA_BASE_6$ULTIMA_TRS, "%b, %Y")
BUSCA_BASE_6$MEDIA_TRS_DIA <- round(BUSCA_BASE_6$MEDIA_TRS_DIA, 2)
BUSCA_BASE_6$MEDIA_VLR_DIA <- round(BUSCA_BASE_6$MEDIA_VLR_DIA, 2)
BUSCA_BASE_6$QTD_TRS <- as.numeric(BUSCA_BASE_6$QTD_TRS)
return(BUSCA_BASE_6)}

