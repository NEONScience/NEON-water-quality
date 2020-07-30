########################################################################################################################
#' @title CalcYSI_eq

#' @author Bobby Hensley \email{hensley@battelleecology.org} \cr

#' @description This R script calculates the dissolved oxygen (DO) percent saturation at local atmospheric pressure
#' from the DO percent saturation reported in the water quality data product (DP1.20288.001), which is
#' referenced to sea level.  This is done by reversing the equation found in the YSI EXO2 Manual to convert local
#' DO percent saturation to sea level percent saturation.
#'
#' The pressure correction factor Fp is given as:
#'
#' Fp = Psl / P
#'
#' where P is the local barometric pressure in atmospheres, Psl is the atmospgeric pressure at sea level, assumed
#' to be 760 mmHg or 101.325 atm.
#'
#' Pressure is obtained from the barometric pressure data product (DP1.00004.001).

#' @param mergedData The output of the getAndFormatData function which contains the necessary formatted data. Columns
#' 1-12 include variables obtained directly from the water quality data product (DP1.20288.001). Descriptions and units
#' of these variables can be found in the readme_20288 file.  Columns 13-14 include variables obtained directly from
#' the barometric pressure data product (DP1.00004.001). Descriptions and units of these variables can be found in the
#' readme_00004 file. Column 15 "atm" is the barometric pressure converted to units of atmospheres.  Columns 16-17 1
#' min interpolated values derived from the 5 min values found in the water temperature data product (DP1.20053.001).
#' Descriptions and units of these variables can be found in the readme_20053 file.   [dataFrame]

#' @return This script returns the percent DO saturation (units %) corrected to local atmospheric pressure, and a
#' quality flag which summarizes the quality flags of the data products used in the calculation.

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @export

#' @example
#' HOPB_DO_data <- getAndFormatData(siteName="HOPB", startDate="2019-08", endDate="2019-09")
#' HOPB_DO_data_YSI <- calcYSI_eq(mergedData = HOPB_DO_data)

# changelog and author contributions / copyrights
#   Bobby Hensley (7/22/2020)
#     Original Creation
########################################################################################################################
calcYSI_eq <- function(
  mergedData=NULL
){
  if(!("dissolvedOxygenSaturation" %in% names(mergedData))){
    stop("Dissolved oxygen saturation (dissolvedOxygenSaturation) data is missing or has wrong column name.")
  }
  if(!("staPresMean" %in% names(mergedData))){
    stop("Mean station pressure (staPresMean) data is missing or has wrong column name.")
  }
  mergedData$YSIMethod<-mergedData$dissolvedOxygenSaturation*(101.325/mergedData$staPresMean)
  mergedData$DissolvedOxygenSatCorrectedQF<-mergedData$dissolvedOxygenSatFinalQF+mergedData$staPresFinalQF
  return(mergedData)
}

