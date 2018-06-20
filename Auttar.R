
base <- read_xlsx("BASE_ATIVA_20062018.xlsx")

base <- normalizar_base(base)

summary(base)

dataCor <- cor(base)
str(base)



base$SITUACAO <- as.numeric(base$SITUACAO)
base$QTDA_HTTPS <- as.numeric(base$QTDA_HTTPS)
base$POS_TEF <- revalue(base$POS_TEF, c("N"=0))
base$POS_TEF <- revalue(base$POS_TEF, c("S"=1))
base$POS_TEF <- as.numeric(base$POS_TEF)

names(base) c("QTD_TRS", "VLR_TRS", "ATIVO", "DIAS", "RANGE", "POS_TEF",
              "QTDA_HTTPS","SITUACAO", "DIAS_BASE", "DAY_TO_ATV", "MEDIA_TRS_DIA",
              "MEDIA_VLR_DIA")

base_cor <- base[,c("QTD_TRS", "VLR_TRS", "ATIVO", "DIAS", "RANGE", "POS_TEF",
                                           "QTDA_HTTPS","SITUACAO", "DIAS_BASE", "DAY_TO_ATV", "MEDIA_TRS_DIA",
                                           "MEDIA_VLR_DIA")]

dataCor <- cor(base_cor)

library(corrplot)
corrplot(dataCor)







