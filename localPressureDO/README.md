NEON Local Dissolved Oxygen % Saturation
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- ****** Description ****** -->

Contains functions to format data and calculate dissolved oxygen (DO) %
saturation at local conditions.

<!-- ****** Usage ****** -->

## Usage

The functions in this package have the following purpose: (1) to format
downloaded data and (2) to calculate DO percent saturation using two
different equations. See help files for individual functions for
details. The general flow of using this package is:

1.  download data from the NEON data portal using getAndFormatData
2.  Calculate dissolved oxygen percent saturation using either
    calcYSI\_eq or calcBK\_eq.

An example workflow:

HOPB\_DO\_data \<- localPressureDO::getAndFormatData(siteName=“HOPB”,
startDate=“2019-08”, endDate=“2019-09”)

HOPB\_DO\_data\_YSI \<- localPressureDO::calcYSI\_eq(mergedData =
HOPB\_DO\_data)
base::write.csv(HOPB\_DO\_data\_YSI,file=“Corrected\_DO\_saturation\_YSI\_corr.csv”)

HOPB\_DO\_data\_both \<- localPressureDO::calcBK\_eq(mergedData =
HOPB\_DO\_data\_YSI)
base::write.csv(HOPB\_DO\_data\_both,file=“Corrected\_DO\_saturation\_both.csv”)

<!-- ****** Acknowledgements ****** -->

## Credits & Acknowledgements

<!-- HTML tags to produce image, resize, add hyperlink. -->

<!-- ONLY WORKS WITH HTML or GITHUB documents -->

<a href="http://www.neonscience.org/">
<img src="logo.png" width="300px" /> </a>

<!-- Acknowledgements text -->

The National Ecological Observatory Network is a project solely funded
by the National Science Foundation and managed under cooperative
agreement by Battelle. Any opinions, findings, and conclusions or
recommendations expressed in this material are those of the author(s)
and do not necessarily reflect the views of the National Science
Foundation.

<!-- ****** License ****** -->

## License

GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

<!-- ****** Disclaimer ****** -->

## Disclaimer

*Information and documents contained within this pachage are available
as-is. Codes or documents, or their use, may not be supported or
maintained under any program or service and may not be compatible with
data currently available from the NEON Data Portal.*
