
#Script for updating the DO % saturation R package

setwd("~/GitHub/NEON-water-quality/localPressureDO")
devtools::document()
devtools::check()

setwd("~/GitHub/NEON-water-quality")
devtools::install("localPressureDO")
library(localPressureDO)

#Testing Package
HOPB_DO_data <- localPressureDO::getAndFormatData(siteName="HOPB", startDate="2019-08", endDate="2019-09")

HOPB_DO_data_YSI <- localPressureDO::calcYSI_eq(mergedData = HOPB_DO_data)
write.csv(HOPB_DO_data_YSI,file="Corrected_DO_saturation_YSI_corr.csv")

HOPB_DO_data_corr <- localPressureDO::calcBK_eq(mergedData = HOPB_DO_data)
write.csv(HOPB_DO_data_corr,file="Corrected_DO_saturation_BK_corr.csv")

HOPB_DO_data_both <- localPressureDO::calcBK_eq(mergedData = HOPB_DO_data_YSI)
write.csv(HOPB_DO_data_both,file="Corrected_DO_saturation_both.csv")
