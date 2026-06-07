#' Pengikat (binding) RStudio Project Template untuk skripsi STIS
#'
#' Fungsi ini dipanggil otomatis oleh RStudio melalui menu
#' **File \eqn{\rightarrow} New Project \eqn{\rightarrow} New Directory \eqn{\rightarrow}
#' Skripsi Komputasi Statistik (Politeknik Statistika STIS)**.
#' Pengguna tidak perlu memanggilnya secara langsung; gunakan [buat_skripsi()]
#' untuk pemakaian dari konsol.
#'
#' @param path Direktori proyek yang dibuat RStudio.
#' @param ... Parameter dari dialog RStudio (judul, subjudul, nama, nim,
#'   peminatan, pembimbing).
#' @return (Secara *invisible*) path proyek.
#' @export
#' @keywords internal
buat_skripsi_rstudio <- function(path, ...) {
  dots <- list(...)

  kosong_jadi_default <- function(x, default) {
    if (is.null(x) || !nzchar(trimws(as.character(x)))) default else x
  }

  # "(otomatis ...)" atau kosong -> NULL agar jenis_skripsi mengikuti peminatan.
  jenis <- dots$jenis_skripsi
  jenis <- if (is.null(jenis) ||
               !nzchar(trimws(as.character(jenis))) ||
               grepl("^\\(otomatis", trimws(as.character(jenis)))) NULL else jenis

  buat_skripsi(
    path       = path,
    judul      = kosong_jadi_default(dots$judul, "TULISKAN JUDUL SKRIPSI ANDA DI SINI"),
    subjudul   = if (is.null(dots$subjudul) || !nzchar(trimws(dots$subjudul))) NULL else dots$subjudul,
    nama       = kosong_jadi_default(dots$nama, "NAMA MAHASISWA"),
    nim        = kosong_jadi_default(dots$nim, "NIM"),
    peminatan  = kosong_jadi_default(dots$peminatan, "Sains Data"),
    jenis_skripsi = jenis,
    pembimbing = kosong_jadi_default(dots$pembimbing, "Nama Dosen Pembimbing"),
    overwrite  = TRUE
  )

  invisible(path)
}
