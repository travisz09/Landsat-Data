###Travis Zalesky
#10/22/2023
#V1.0

#Acknowledgements:
## Thank you to the University of Arizona and to Dr. Matthew Marcus
##  for teaching me how to access, process and visualize Landsat
##  data in R. Portions of this script have been borrowed from 
##  lesson plans provided by Dr. Marcus.

#Objectives: 
### To learn how to import, visualize and explore Landsat satellite 
###     data using basic raster functions in R.

#Setup ----
#Packages
##Use install.packages("terra") if not previously installed on your machine.
#install.packages("terra") #Note out after installation.
library(terra) #Load package

#Set Working Directory (WD) - User input required.
## Set WD to a logical location with a descriptive folder name.
## Use choose.dir() to interactively select desired directory.
wd <- choose.dir() #save wd as a string.
setwd(wd) #set wd.
getwd() #check wd.
dir() #Explore wd.

#Create a separate folder for Data, useful for untaring function.
suppressWarnings(dir.create("Data")) #Create folder in wd.
dir(wd) #Explore wd

#ATTN: If you have not already, save your .tar file in your Data folder.

dir("Data") #Explore Data folder, should contain compressed data folder.

#Untar data file - user input required.
##Check wd/Data for n files
##if Data folder contains exactly 1 file with .tar extension.
if (length(list.files(path = "Data"))==1 &
    is.character(list.files(path = "Data", pattern = ".tar"))==1) {
  #Get .tar filename.
  tarFile <- list.files(path = "Data",
                        pattern = ".tar")
  #Untar file.
  untar(paste("Data", tarFile, sep ="/"), 
        exdir = "Data")##untar files to wd/Data.
  #Alternate - use file.choose() for interactive file selection.
  
  #Else, do nothing. Files have already been extracted.
} #end if

#After untaring wd/Data should contain ~20 files.
dir(path = "Data") #Explore wd/Data

#Create list of extracted .tif files.
#NOTE 1: For Landsat 8 and 9 bands 1-7 are the most frequently used.
##   Warning! Panchromatic band 8 uses a different extent and my create errors.
##   See https://www.google.com/search?client=firefox-b-1-d&q=landsat+9+bands
##   for details regarding Landsat instruments and bands.
ls <- list.files(pattern = 'B[1-7,9]\\d?.TIF', #All bands except panchromatic band 8.
  path = 'Data')

pan <- list.files(pattern = 'B8.TIF', 
                  path = 'Data')

ls #check list

#NOTE 2: ls is alphabetized with "...B1.TIF" followed by 
##   "...B10.TIF". Reorder ls items by band for more logical workflow.
#Reorder by index position.
ls <- ls[c(1, 4:9, 1, 10, 2, 3)]#Double up band 1 in position 8 as a placeholder.

ls #check list

#The rast() function brings in the files into the R environment as rasters. 
## Specifically, as SpatRasters.
## paste function required to navigate to Data folder containing files listed by ls.
LSat <- rast(paste("Data/", ls, sep = ""))
LSat_Pan <- rast(paste("Data/", pan, sep = ""))

#Explore Data ----
LSat #Provides the spatial information associated with the downloaded image.

crs(LSat) #Shows the spatial projection of the Landsat image.

ext(LSat) #Shows the coordinates of the geographic corners of the image.

nlyr(LSat) #Shows the number of layers.

xres(LSat) #Shows the spatial resolution in the x axis.

yres(LSat) #Shows the spatial resolution in the y axis.

res(LSat) #Shows the spatial resolution in the x,y axis.

ncell(LSat) #Shows the number of pixels in the image.

dim(LSat) #Shows rows, columns, and bands

#Plot Data ----
##NOTE 3: All band values below are for Landsat 8 or 9. See
##   https://www.google.com/search?client=firefox-b-1-d&q=landsat+bands
##   for additional Landsat bands including older units.

##NOTE 4: stretch = "lin" (linear) stretches the image across all
##  available brightness values using a linear function. Other
##  values of stretch = "hist" or NULL. In my opinion linear looks
##  best for most images, but your results may vary (see below).

plot(LSat_Pan)
##Select desired LSat bands and assign them to RGB to visualize.
##For Landsat 8 and 9 natural color is shown as bands 4, 3, and 2
##  for red (r), green (g), and blue (b) respectively.
plotRGB(LSat, r = 4, g = 3, b = 2, axes = FALSE, 
        stretch = "lin") #use angle = 15 to correct plot skew. ANGLE NOT COMPATABLE WITH DRAW!

#Interactive crop and zoom plotRGB - user input required.
##For draw() to work, your zoom settings on RStudio have to be set to
## 100%. If you zoom in further to make the image appear bigger,
## draw() will select offset points from where you click on the image.
## This is an annoying bug in RStudio.
e <- draw(x = "extent") #Interactive extent picker for plotRgb.
LSat_e <- crop(LSat,e) #Crop image to chosen extent

#Plot cropped data.
plotRGB(LSat_e, r = 4, g = 3, b = 2, axes = FALSE, 
        stretch = "lin") 

#Alternate method for cropping data.
##Define fixed extent.
ext(LSat) #Explore data extent (coordinates).
##Modify extnt to values within the range of ext(LSat).
extnt <- c(400000, 500000, 5250000, 5350000)
plotRGB(LSat, r = 4, g = 3, b = 2, axes = FALSE, 
        stretch = "lin", ext = extnt)

#False Color Images.
##False color composite 1, with linear stretch.
##Bands 5 = NIR, 4 = red, and 3 = green (Landsat 9).
plotRGB(LSat_e, r = 5, g = 4, b = 3, axes = FALSE, 
        stretch = 'lin') 

##False color composite 2, with linear stretch
##Bands 6 = SWIR 1, 5 = NIR, and 4 = red (Landsat 9).
plotRGB(LSat_e, r = 6, g = 5, b = 4, axes = FALSE, 
        stretch = 'lin')

##False color composite 3, with linear stretch
##Bands 10 = LWIR 1, 6 = SWIR, and 2 = blue (Landsat 9).
##Thermal imagery for fire spotting.
plotRGB(LSat_e, r = 10, g = 5, b = 2, axes = F, 
        stretch = 'lin')

#Histogram Plots (see NOTE 2 above).
dev.off() #Fixes unexpected results when plotting histograms.
#Insert desired band into double brackets.
hist(LSat_e[[2]], main = "Band 2 Histogram",
     xlab = "Value", ylab = "Frequency") 

#Calculate Index Values----
##NOTE 4: Indexes are values calculated by the difference between
##    two wavelengths divided by the sum of the same two wavelengths,
##    sometimes also containing a correction factor or other constant.
##    The resulting calculation is typically a normalized, unitless 
##    value ranging between -1 to 1. Depending on the wavelengths
##    used different surface features can be visualized based
##    on their spectral characteristics. Many indexes have been
##    developed to emphasize particular phenomenon on the earth,
##    these are just a few of the most commonly used.

#NDVI
##Calculate the Normalized Difference Vegetation Index (NDVI).
##Used to detect vegetation and monitor vegetation health.
# NDVI = (NIR - Red) / (NIR + Red)
ndvi <- ((LSat_e[[5]] - LSat_e[[4]]) / (LSat_e[[5]] + LSat_e[[4]]))
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")

##Calculate the Normalized Difference Built-up Index (NDBI).
##Used to detect buildings and other constructed environments.
# NDBI = (SWIR1 - NIR) / (SWIR1 + NIR)
ndbi <- ((LSat_e[[6]] - LSat_e[[5]]) / (LSat_e[[6]] + LSat_e[[5]]))
plot(ndbi, main = "Normalized Difference Built-Up Index", axes = F)

##Calculate the Normalized Difference Water Index (NDWI)
##Used to detect moisture, not including open water.
# NDWI = (NIR - SWIR1) / (NIR + SWIR1)
ndwi <- ((LSat_e[[5]] - LSat_e[[6]]) / (LSat_e[[5]] + LSat_e[[6]]))
plot(ndwi, main = "Normalized Difference Water Index", axes = F)

##Calculate the Modified Normalized Difference Water Index (MNDWI).
##Used to detect water bodies.
# MNDWI = ((green - NIR)/(green + NIR))
mndwi <- ((LSat_e[[3]] - LSat_e[[5]]) / (LSat_e[[3]] + LSat_e[[5]]))
plot(mndwi, main = "Modified Normalized Difference Water Index", axes = F) 

##Insert band number into the double brackets to create your own index.
#user_index <- ((LSat_e[[]] - LSat_e[[]]) / (LSat_e[[]] + LSat_e[[]]))
#plot(user_index, main = "My Index", axes = F) 

#Saving an image----
##Use the appropriate function for the file type you desire following
##   the structure below.

# png(filename = "example.png") #specify filepath in filename if desired.
# plot(...)
# dev.off()

#.png
png("Images/NDVI.png")
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")
dev.off()

#.jpeg
jpeg("Images/NDVI.jpeg")
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")
dev.off()

#.bmp
bmp("Images/NDVI.bmp")
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")
dev.off()

#.tiff
tiff("Images/NDVI.tiff")
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")
dev.off()

#.pdf
pdf("Images/NDVI.pdf")
plot(ndvi, axes = F, main = "Normalized Difference Vegetation Index")
dev.off()

##To publish ----
extnt <- c(380000, 555000, 5200000, 5350000)
png(filename = "Images/Peninsula.png")
plotRGB(LSat, r = 4, g = 3, b = 2, axes = F, 
        stretch = "lin", ext = extnt, mar = 1.5)+
  title(main = "The Olympic Peninsula", 
        cex.main = 3, line = -1)
dev.off()
  
LSat_e <- crop(LSat,extnt)
ndvi <- ((LSat_e[[5]] - LSat_e[[4]]) / (LSat_e[[5]] + LSat_e[[4]]))
png(filename = "Images/NDVI.png")
plot(ndvi, axes = F)+
  title(main = "Normalized Difference Vegetation Index", 
        cex.main = 1.5, line = -1)
dev.off()

extnt <- c(450000, 470000, 5280000, 5290000)
png(width = 490, height = 330, filename = "Images/ThermalImagery2.png")
plotRGB(LSat, r = 10, g = 5, b = 2, axes = F, 
        stretch = "lin", ext = extnt)+
  title(main = "Thermal Imagery of Active Fires", 
        cex.main = 1.5, line = -1)+
  title(sub = "Olympic National Park, 9/16/2023",
        line = -21.5)
dev.off()
