\name{buat_skripsi_rstudio}
\alias{buat_skripsi_rstudio}
\title{Pengikat (binding) RStudio Project Template untuk skripsi STIS}
\usage{
buat_skripsi_rstudio(path, ...)
}
\arguments{
\item{path}{Direktori proyek yang dibuat RStudio.}

\item{...}{Parameter dari dialog RStudio (judul, subjudul, nama, nim,
peminatan, pembimbing).}
}
\value{
(Secara \emph{invisible}) path proyek.
}
\description{
Fungsi ini dipanggil otomatis oleh RStudio melalui menu
\strong{File \eqn{\rightarrow} New Project \eqn{\rightarrow} New Directory \eqn{\rightarrow}
Skripsi Komputasi Statistik (Politeknik Statistika STIS)}.
Pengguna tidak perlu memanggilnya secara langsung; gunakan \code{\link{buat_skripsi}}
untuk pemakaian dari konsol.
}
\keyword{internal}
