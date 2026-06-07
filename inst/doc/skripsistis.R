## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval = FALSE-------------------------------------------------------------
#  # di terminal
#  quarto install tinytex

## ----eval = FALSE-------------------------------------------------------------
#  # dari berkas sumber (.tar.gz)
#  install.packages("skripsistis_0.2.1.tar.gz", repos = NULL, type = "source")
#  
#  # atau dari GitHub
#  # remotes::install_github("madsyair/skripsistis")

## ----eval = FALSE-------------------------------------------------------------
#  library(skripsistis)
#  
#  buat_skripsi(
#    path        = "skripsi-saya",
#    judul       = "Pemodelan Proxy Means Test Berbasis GPBoost di Provinsi Jawa Timur",
#    nama        = "Nama Mahasiswa",
#    nim         = "222212501",
#    peminatan   = "Sains Data",
#    ketua_prodi = "Nama Ketua Program Studi",
#    pembimbing  = "Nama Pembimbing",
#    render      = FALSE   # set TRUE untuk langsung membuat PDF
#  )

## -----------------------------------------------------------------------------
library(skripsistis)
dir <- file.path(tempdir(), "contoh-skripsi")
suppressMessages(
  buat_skripsi(dir, judul = "Judul Contoh", nama = "Nama Mahasiswa",
               nim = "222212501", peminatan = "Sains Data", overwrite = TRUE)
)
# tampilkan berkas-berkas yang dibuat
cat(list.files(dir, recursive = TRUE), sep = "\n")

## ----eval = FALSE-------------------------------------------------------------
#  # dari R
#  skripsistis::render_skripsi("skripsi-saya")
#  
#  # atau langsung dari terminal
#  # quarto render skripsi-saya

## -----------------------------------------------------------------------------
dat <- data.frame(Daerah = c("Perkotaan", "Perdesaan"),
                  Persentase = c(7.00, 12.86))
knitr::kable(dat, format.args = list(decimal.mark = ","))

## -----------------------------------------------------------------------------
x <- 1:10
plot(x, x^2, xlab = "Sumbu $\\alpha$", ylab = "$\\sigma^2$")

## -----------------------------------------------------------------------------
skripsistis::path_csl()

