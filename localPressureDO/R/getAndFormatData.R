########################################################################################################################
#' @title getAndFormatData

#' @author Bobby Hensley \email{hensley@battelleecology.org} \cr

#' @description This R script that downloads and formats the data necessary to correct dissolved oxygen (DO) percent
#' saturation to local atmospheric pressure from the DO percent saturation reported in the water quality data product
#' (DP1.20288.001), which is referenced to sea level.  This can be done using either the Benson-Krause
#' equation used by the USGS, or a simplified version found in the YSI EXO2 manual.
#'
#' The relevant data products are:
#'
#' water quality (DP1.20288.001)
#' barometric pressure (DP1.00004.001)
#' water temperature (DP1.20053.001) - Note water temp is only used for Benson-Krause method.

#' @import neonUtilities
#' @import zoo

#' @param siteName The 4 digit NEON site code, e.g. "LEWI" [character]
#' @param startDate The data start date foratted as "YYYY-MM" [character]
#' @param endDate The data end date foratted as "YYYY-MM" [character]

#' @return This script produces table of properly formatted data.

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @export

#' @example
#' getAndFormatData(siteName="HOPB", startDate="2019-08", endDate="2019-09")

# changelog and author contributions / copyrights
#   Bobby Hensley (7/22/2020)
#     Original Creation
########################################################################################################################
getAndFormatData <- function(
  siteName=NULL,
  startDate=NULL,
  endDate=NULL
){
  if(is.null(siteName)|!grepl("[A-Z]{4}",siteName)){
    stop("siteName must be specified.")
  }
  if(is.null(startDate)|!grepl("[0-9]{4}-[0-9]{2}",startDate)){
    stop("startDate must be present and formatted as YYYY-MM")
  }
  if(is.null(endDate)|!grepl("[0-9]{4}-[0-9]{2}",endDate)){
    stop("endDate must be present and formatted as YYYY-MM")
  }
  #'Pulls and prepares L1 water quality data (DP1.20288.001)
  sondeData<-neonUtilities::loadByProduct(dpID="DP1.20288.001", site=siteName, startdate=startDate,
                                          enddate=endDate, package="basic", check.size = F)
  base::list2env(sondeData, .GlobalEnv)
  waq_instantaneous<-waq_instantaneous[,c("domainID","siteID","horizontalPosition","verticalPosition","startDateTime",
                                          "endDateTime","specificConductance","specificCondFinalQF","dissolvedOxygen",
                                          "dissolvedOxygenFinalQF","dissolvedOxygenSaturation","dissolvedOxygenSatFinalQF")]
  waq_instantaneous$startDateTime<-as.POSIXct(round.POSIXt(waq_instantaneous$startDateTime,units="mins"),
                                              format="%Y-%m-%dT%H:%M", tz="UTC")
  waq_instantaneous$endDateTime<-as.POSIXct(round.POSIXt(waq_instantaneous$endDateTime,units="mins"),
                                            format="%Y-%m-%dT%H:%M", tz="UTC")

  #' Pulls L1 barometeric pressure data (DP1.00004.001)
  barometerData<-neonUtilities::loadByProduct(dpID="DP1.00004.001", site=siteName, startdate=startDate,
                                              enddate=endDate, package="basic", check.size = F)
  list2env(barometerData, .GlobalEnv)
  BP_1min<-BP_1min[,c("startDateTime","staPresMean","staPresFinalQF")]
  BP_1min$startDateTime<-as.POSIXct(round.POSIXt(BP_1min$startDateTime,units="mins"),format="%Y-%m-%dT%H:%M", tz="UTC")
  BP_1min$atm<-BP_1min$staPresMean*0.00986923

  #' Pulls L1 water temperature data (DP1.20053.001)
  prtData<-neonUtilities::loadByProduct(dpID="DP1.20053.001", site=siteName, startdate=startDate,
                                        enddate=endDate, package="basic", check.size = F)
  list2env(prtData, .GlobalEnv)
  TSW_5min<-TSW_5min[,c("startDateTime","horizontalPosition","surfWaterTempMean","finalQF")]
  names(TSW_5min)<-c("startDateTime","horizontalPosition","surfWaterTempMean","TSWfinalQF")
  TSW_5min$startDateTime<-as.POSIXct(round.POSIXt(TSW_5min$startDateTime,units="mins"),format="%Y-%m-%dT%H:%M",tz="UTC")

  #' Merges datasets using timestamp
  mergedData<-merge(waq_instantaneous,BP_1min,by.x="startDateTime",by.y="startDateTime",all.x=T,all.y=F)
  mergedData<-merge(mergedData,TSW_5min,by.x=c("horizontalPosition","startDateTime"),
                    by.y=c("horizontalPosition","startDateTime"),all.x=T,all.y=F)

  #' Fills missing 1 min water temperature values using spline interpolation
  mergedData$surfWaterTempMean<-zoo::na.spline(mergedData$surfWaterTempMean)
  mergedData$TSWfinalQF<-ceiling(zoo::na.spline(mergedData$TSWfinalQF))

  return(mergedData)
}

