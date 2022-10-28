# Mean_Nitrate_Concentration_Drivers_CONUS

Here, the mean nitrate concentrations and the site characteristics of 2061 sites used in the paper "Sadayappan, Kerins, Shen, Li" are available along with the R code to construct the calibrated Boosted Regression Tree model used to predice long term mean nitrate concentrations across CONUS in the paper. 

Nitrate concentrations were downloaded from United States Geological Survey (USGS) Water Data (U.S. Geological Survey, 2016) using the USGS-R dataRetrieval package (Hirsch and De Cicco 2015). Mean nitrate levels were calculated as arithmetic mean for those sites with atleast 10 measurements after removing below detection limit measurements. 

Geospatial Attributes of Gages for Evaluating Streamflow (GAGES II) database (Falcone 2011) was used to get characteristics of the sites.

Calculate mean nitrate concentration for ungauged basins: If you have nitrate application rate (Kg/Km2/yr), percent developed area (%), mean annual precipitation (cm/yr), mean annual temperature (degree C) and sand soil content (weight percentage), insert own values in "code_BRT_model" to get mean nitrate concentration as estimated by median model as well as mean concentrations as estimated by 1000 BRT models to get uncertainty range.

References:

U.S. Geological Survey, 2016, National Water Information System data available on the World Wide Web (USGS Water Data for the Nation), accessed [November, 2020], at URL [http://waterdata.usgs.gov/nwis/].

Falcone, J. A. (2011). GAGES-II: Geospatial attributes of gages for evaluating streamflow, US Geological Survey.

Hirsch, R. M. and L. A. De Cicco (2015). User guide to Exploration and Graphics for RivEr Trends (EGRET) and dataRetrieval: R packages for hydrologic data, US Geological Survey.

