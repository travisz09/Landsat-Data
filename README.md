# Landsat-Data
Download analyize and display data from Landsat satelites.

To begin you will need an Earth Explorer account. Please visit https://earthexplorer.usgs.gov/ to set up your free account.

Next use the USGS Earth Explorer interface to search for an area of interest. You can use the map or search for locations. Once you have made a sellection click the "Data Sets" tab to choose your data. There are many avalible datasets provided by the USGS but this tutorial is specificly designed for LandSat 8 or 9. Use the file tree on the left to select Landsat/Landsat Collection 2 Level-1/Landsat 8-9 OLI/TIRS C1 Level-1. Click the "Results" tab to proceed. Scroll through your results. Examine the thumbnails. Examine the Metadata. Look for an image taken durring the day, with a low cloud cover and a high image quality (these parameters can also be specified under "Additional Criteria" to filter results). Select your desired image. Click "Download Options". Click "Product Options". Choose the Product Bundle option at the top to get all layers as a compressed .tar file (large file).

Now you are ready to begin exploring Landsat imagery with R. Follow the provided R script and enjoy!
