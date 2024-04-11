rm(list = ls())
# The named file below is output from fv
library(magick)

df = read.csv("./stat679final/data/sdss_dr16.csv",stringsAsFactors=FALSE,skip=1)

df$ra = as.numeric(df$ra)
df$dec = as.numeric(df$dec)
# df$subclass = trimws(df$subclass, which="right")

df$plateid = as.numeric(df$plateid)
# df$mjd = as.numeric(df$mjd)
df$fiberid = as.numeric(df$fiberid)
df$fiber = as.numeric(df$fiber)
# n = 100000
# type = c("passive","starform","agn")
# subclass = c("","STARFORMING","AGN")

classes = unique(df$class)

library(parallel)

# 设置并行计算的核心数
no_cores <- detectCores() - 1
cl <- makeCluster(no_cores)
download_with_retry <- function(url, path, retries = 5, delay = 5) {
  for(i in 1:retries) {
    tryCatch({
      download.file(url, path, mode = "wb")
      if(file.exists(path)) break # 如果文件成功下载，退出循环
    }, error = function(e) {
      if(i == retries) stop("Failed to download after retries: ", e)
      Sys.sleep(delay) # 等待一段时间后重试
    })
  }
}
# 在集群的每个节点上加载必要的包
clusterEvalQ(cl, {
  library(magick)
})
clusterExport(cl, varlist = c("download_with_retry"), envir = environment())
classes = unique(df$class)

for (jj in 1:3) {
  w = which(df$class == classes[jj])
  n = length(w)
  set.seed(7)
  s = sample(length(w), n)
  df.new = df[w[s], ]
  
  # 创建图像目录
  image_directory <- trimws(classes[jj], which="right")
  dir.create(image_directory, recursive = TRUE, showWarnings = FALSE)
  
  # 构造下载任务列表
  tasks <- lapply(1:n, function(ii) {
    list(url = paste0("http://skyserver.sdss.org/dr16/SkyServerWS/ImgCutout/getjpeg?ra=", df.new$ra[ii], "&dec=", df.new$dec[ii], "&scale=0.4&width=64&height=64"),
         file_path = paste0(image_directory, "/", trimws(classes[jj], which="right"), "_", ii, ".jpg"))
  })
  
  
  # 在并行下载函数中使用download_with_retry
  parLapply(cl, tasks, function(task) {
    download_with_retry(task$url, task$file_path)
  })
  # # 并行下载
  # parLapply(cl, tasks, function(task) {
  #   download.file(task$url, task$file_path, mode = "wb")
  # })
}

# 关闭集群
stopCluster(cl)

#----------------------

no_cores <- detectCores() - 1
cl <- makeCluster(no_cores)
download_with_retry <- function(url, path, retries = 5, delay = 5) {
  for(i in 1:retries) {
    tryCatch({
      download.file(url, path, mode = "wb")
      if(file.exists(path)) break # 如果文件成功下载，退出循环
    }, error = function(e) {
      if(i == retries) stop("Failed to download after retries: ", e)
      Sys.sleep(delay) # 等待一段时间后重试
    })
  }
}
# 在集群的每个节点上加载必要的包
clusterEvalQ(cl, {
  library(magick)
})
clusterExport(cl, varlist = c("download_with_retry"), envir = environment())
classes = unique(df$class)

for (jj in 1:3) {
  w = which(df$class == classes[jj])
  #n = length(w)
  n = 100
  set.seed(7)
  s = sample(length(w), n)
  df.new = df[w[s], ]
  
  # 创建图像目录
  image_directory <- trimws(classes[jj], which="right")
  dir.create(image_directory, recursive = TRUE, showWarnings = FALSE)
  
  # 构造下载任务列表
  tasks <- lapply(1:n, function(ii) {
    list(url = paste0("https://skyserver.sdss.org/dr16/en/get/SpecByPF.ashx?P=",
                      df.new$plateid[ii], "&F=", df.new$fiber[ii],
                      "&submit1=Get+Spectrum"),
         file_path = paste0(image_directory, "/", trimws(classes[jj], which="right"), "_", ii, ".jpg"))
  })
  
  
  # 在并行下载函数中使用download_with_retry
  parLapply(cl, tasks, function(task) {
    download_with_retry(task$url, task$file_path)
  })
  # # 并行下载
  # parLapply(cl, tasks, function(task) {
  #   download.file(task$url, task$file_path, mode = "wb")
  # })
}

# 关闭集群
stopCluster(cl)



