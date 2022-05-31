########################################################################################################################
#' @title CalcBK_eq

#' @author Bobby Hensley \email{hensley@battelleecology.org} \cr

#' @description This R script calculates the dissolved oxygen (DO) percent saturation at local atmospheric pressure
#' from the DO percent saturation reported in the water quality data product (DP1.20288.001), which is
#' referenced to sea level.  This is done using the Benson-Krause pressure correction factor found in Standard Methods
#' (2005) and used by the USGS since 2011.
#'
#' The pressure correction factor Fp is given as:
#'
#' Fp = (P-u)(1-zP) / (1-u)(1-z)
#'
#' where P is the barometric pressure in atmospheres, u is the vapor pressure of water in atmospheres, and z is related
#' to the second virial coefficient of oxygen.
#'
#' u = exp(11.8571 - (3840.7/(T+273.15)) - (216961/(T+273.15)^2))
#'
#' and
#'
#' z = 0.000975 - 0.00001426T + 0.00000006436T^2
#'
#' where T is water temperature in degrees C.
#'
#' Pressure is obtained from the barometric pressure data product (DP1.00004.001), and water temperature is obtained
#' from the water temperature data product (DP1.20053.001).

#' @param mergedData The output of the getAndFormatData function which contains the necessary formatted data. Columns
#' 1-12 include variables obtained directly from the water quality data product (DP1.20288.001). Descriptions and units
#' of these variables can be found in the readme_20288 file.  Columns 13-14 include variables obtained directly from
#' the barometric pressure data product (DP1.00004.001). Descriptions and units of these variables can be found in the
#' readme_00004 file. Column 15 "atm" is the barometric pressure converted to units of atmospheres.  Columns 16-17 1
#' min interpolated values derived from the 5 min values found in the water temperature data product (DP1.20053.001).
#' Descriptions and units of these variables can be found in the readme_20053 file.   [dataFrame]

#' @import zoo

#' @return This script returns the percent DO saturation (units %) corrected to local atmospheric pressure, and a
#' quality flag which summarizes the quality flags of the data products used in the calculation.

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @export

#' @example
#' HOPB_DO_data <- getAndFormatData(siteName="HOPB", startDate="2019-08", endDate="2019-09")
#' HOPB_DO_data_corr <- calcBK_eq(mergedData = HOPB_DO_data)

# changelog and author contributions / copyrights
#   Bobby Hensley (7/22/2020)
#     Original Creation
########################################################################################################################
calcBK_eq <- function(
  mergedData=NULL
){
  if(!("surfWaterTempMean" %in% names(mergedData))){
    stop("Surface water temp (surfWaterTempMean) data is missing or has wrong column name.")
  }
  if(!("staPresMean" %in% names(mergedData))){
    stop("Mean surface water pressure (staPresMean) data is missing or has wrong column name.")
  }
  if(!("seaLevelDissolvedOxygenSat" %in% names(mergedData))){
    stop("Dissolved oxygen saturation (seaLevelDissolvedOxygenSat) data is missing or has wrong column name.")
  }
  #' Calculates corrected percent saturation using Benson-Krause equation.
  mergedData$vapPres<-exp(11.8571 - (3840.7/(mergedData$surfWaterTempMean+273.15))-(216961/((mergedData$surfWaterTempMean+273.15)^2)))
  mergedData$theta<- 0.000975 - (0.00001426*mergedData$surfWaterTempMean) + (0.00000006436*(mergedData$surfWaterTempMean^2))
  mergedData$Fp<-((mergedData$staPresMean - mergedData$vapPres)*(1-(mergedData$theta*mergedData$staPresMean)))/((1-mergedData$vapPres)*(1-mergedData$theta))
  mergedData$dissolvedOxygenSatCorrected<-mergedData$seaLevelDissolvedOxygenSat*(100/mergedData$Fp)
  #' Carries over any DO saturation or barometric pressure quality flags into corrected DO saturation quality flag
  mergedData$DissolvedOxygenSatCorrectedQF<-mergedData$seaLevelDOSatFinalQF+mergedData$staPresFinalQF+mergedData$TSWfinalQF

  return(mergedData)
}
