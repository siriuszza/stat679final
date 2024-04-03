# The named file below is output from fv
library(magick)

df = read.csv("./data/sdss_dr16.csv",
              stringsAsFactors=FALSE,
              header = F)[-1,]
colnames(df) = df[1,]
df = df[-1,]
df$ra = as.numeric(df$ra)
df$dec = as.numeric(df$dec)

write.csv(df, "./data/sdss_dr16_clean.csv", row.names = F)

# df$subclass = trimws(df$subclass, which="right")

# df$plateid = as.numeric(df$plateid)
# df$mjd = as.numeric(df$mjd)
# df$fiberid = as.numeric(df$fiberid)

# n = 100000
# type = c("passive","starform","agn")
# subclass = c("","STARFORMING","AGN")

classes = unique(df$class)

for ( jj in 1:3 ) {
  w = which(df$class == classes[jj])
  n = length(w)
  #print(length(w))
  set.seed(7)
  s = sample(length(w), n)
  #print(s)
  df.new = df[w[s], ]

  # Create a directory to save images
  image_directory <- trimws(classes[jj], which="right")
  dir.create(image_directory)
  
  # Loop to download and save images
  for (ii in 1:n) {
    # Construct the URL
    url <- paste0("http://skyserver.sdss.org/dr16/SkyServerWS/ImgCutout/getjpeg?ra=",
                  df.new$ra[ii], "&dec=", df.new$dec[ii], "&scale=0.4&width=64&height=64")
    
    # Specify the file path where the image will be saved
    file_path <- paste0(image_directory, "/", 
                        trimws(classes[jj], which="right")
                        , "_", ii, ".jpg")
    
    # Download the file
    download.file(url, file_path, mode = "wb")
  }
  
  
  spec_directory <- paste0(trimws(classes[jj], which="right"),
                           "_spec")
  dir.create(spec_directory)
  
  for (ii in 1:n) {
    # Construct the URL for spectrum data
    spec_url <- paste0("https://skyserver.sdss.org/dr16/en/get/SpecByPF.ashx?P=",
                       df.new$plateid[ii], "&F=", df.new$fiberid[ii],
                       "&submit1=Get+Spectrum")
    
    # Specify the file path where the spectrum will be saved
    spec_file_path <- paste0(spec_directory, "/", classes[jj], "_spectrum_", ii, ".jpg")
    
    # Download the spectrum file
    download.file(spec_url, spec_file_path, mode = "wb")
    
    image <- image_read(spec_file_path)
    cropped_image <- image_crop(image, "870x570+130+120")
    image_write(cropped_image, spec_file_path)
  }
  # strings = rep("",n)
  # for ( ii in 1:n ) {
  #   strings[ii] = paste0("<IMG SRC=\"http://skyserver.sdss.org/dr16/SkyServerWS/ImgCutout/getjpeg?ra=",
  #                        df.new$ra[ii],"&dec=",df.new$dec[ii],"&scale=0.4&width=64&height=64\">")
  # }
  # tab = data.frame(strings)
  # write.table(tab,
  #             file=paste0(classes[jj],".html"),
  #             col.names=FALSE,
  #             row.names=FALSE,
  #             quote=FALSE)
}



