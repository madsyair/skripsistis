\name{buat_skripsi}
\alias{buat_skripsi}
\title{Buat proyek Quarto skripsi Politeknik Statistika STIS}
\usage{
buat_skripsi(
  path = "skripsi-stis",
  judul = "TULISKAN JUDUL SKRIPSI ANDA DI SINI",
  subjudul = NULL,
  nama = "NAMA MAHASISWA",
  nim = "NIM",
  peminatan = c("Sains Data", "Sistem Informasi Statistik"),
  jenis_skripsi = NULL,
  pembimbing = "Nama Dosen Pembimbing",
  nip_pembimbing = "0000",
  penguji1 = "Nama Dosen Penguji I",
  nip_penguji1 = "0000",
  penguji2 = "Nama Dosen Penguji II",
  nip_penguji2 = "0000",
  ketua_prodi = "Nama Ketua Program Studi",
  nip_ketua_prodi = "0000",
  tahun = format(Sys.Date(), "\%Y"),
  overwrite = FALSE,
  render = FALSE
)
}
\arguments{
\item{path}{Direktori tujuan proyek (akan dibuat).}
\item{judul}{Judul skripsi (tanpa subjudul).}
\item{subjudul}{Subjudul skripsi (opsional, \code{NULL} jika tidak ada).}
\item{nama}{Nama mahasiswa.}
\item{nim}{Nomor Induk Mahasiswa.}
\item{peminatan}{Peminatan: \code{"Sains Data"} atau
\code{"Sistem Informasi Statistik"}. Menentukan label peminatan pada sampul.}
\item{jenis_skripsi}{Jenis/struktur skripsi yang menentukan kerangka bab,
terlepas dari peminatan: \code{"Analisis"} (Bab I-V: Pendahuluan, Tinjauan
Pustaka, Metode, Hasil dan Pembahasan, Kesimpulan) atau
\code{"Pengembangan Sistem"} (Bab I-VI: Pendahuluan, Tinjauan Pustaka, Metode,
Analisis dan Perancangan, Implementasi dan Evaluasi, Kesimpulan). Bila
\code{NULL} (default), jenis disesuaikan otomatis dengan \code{peminatan}
(Sains Data \eqn{\to} "Analisis"; Sistem Informasi Statistik \eqn{\to}
"Pengembangan Sistem"). Dengan parameter ini, mahasiswa Sains Data dapat
menulis skripsi bertipe pengembangan sistem dan sebaliknya.}
\item{pembimbing, nip_pembimbing}{Nama dan NIP dosen pembimbing.}
\item{penguji1, nip_penguji1}{Nama dan NIP Penguji I.}
\item{penguji2, nip_penguji2}{Nama dan NIP Penguji II.}
\item{ketua_prodi, nip_ketua_prodi}{Nama dan NIP Ketua Program Studi.}
\item{tahun}{Tahun (default tahun berjalan).}
\item{overwrite}{Bila \code{TRUE}, menimpa direktori yang sudah ada.}
\item{render}{Bila \code{TRUE}, langsung menjalankan \code{quarto render}.}
}
\value{
(Secara \emph{invisible}) path absolut proyek yang dibuat.
}
\description{
Menyalin kerangka proyek Quarto skripsi STIS ke direktori baru dan mengisi
metadata secara otomatis. Gaya kutipan dan daftar pustaka mengikuti APA edisi
ke-7 dengan modifikasi bahasa Indonesia.
}
\examples{
\dontrun{
# Skripsi analisis (default untuk Sains Data)
buat_skripsi(
  path = "skripsi-saya",
  judul = "Pemodelan PMT Berbasis GPBoost di Provinsi Jawa Timur",
  nama = "Nama Mahasiswa",
  nim = "222212501",
  peminatan = "Sains Data",
  ketua_prodi = "Nama Ketua Program Studi",
  pembimbing = "Nama Pembimbing",
  render = TRUE
)

# Mahasiswa Sains Data menulis skripsi PENGEMBANGAN SISTEM
buat_skripsi(
  path = "skripsi-sd-sistem",
  judul = "Pengembangan Dasbor Monitoring Kemiskinan Berbasis Web",
  nama = "Nama Mahasiswa",
  nim = "222212501",
  peminatan = "Sains Data",
  jenis_skripsi = "Pengembangan Sistem"
)
}
}
