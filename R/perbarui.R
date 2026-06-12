# Mekanisme "perbarui paket -> perbaikan langsung berlaku" tanpa menyusun ulang.
#
# Sebagian infrastruktur (format) DIKELOLA paket: preamble, CSL, pemindai
# singkatan, dan rujukan perintah. Berkas ini disegarkan dari paket terpasang
# saat render (atau lewat perbarui_template()), sehingga perbaikan format cukup
# dilakukan dengan memperbarui paket lalu render ulang. Isi skripsi mahasiswa
# (folder bab/, referensi.bib, singkatan.csv, img/, index.qmd, _quarto.yml,
# tex/00_frontmatter.tex) TIDAK PERNAH disentuh.

.versi_paket <- function() {
  tryCatch(as.character(utils::packageVersion("skripsistis")),
           error = function(e) "0")
}

# Konfigurasi proyek (ditulis buat_skripsi); dipakai untuk menyegarkan berkas
# terkelola dengan opsi yang sama. Format sederhana "kunci: nilai".
.tulis_konfig <- function(path, peminatan, jenis_skripsi, mode_singkatan) {
  baris <- c(
    "# Konfigurasi proyek skripsistis (dipakai untuk pembaruan berkas terkelola).",
    "# Jangan diedit manual kecuali Anda paham konsekuensinya.",
    paste0("peminatan: ", peminatan),
    paste0("jenis_skripsi: ", jenis_skripsi),
    paste0("singkatan: ", mode_singkatan),
    paste0("versi_paket: ", .versi_paket())
  )
  writeLines(baris, file.path(path, "_skripsistis.yml"))
}

.baca_konfig <- function(path) {
  f <- file.path(path, "_skripsistis.yml")
  if (!file.exists(f)) return(NULL)
  baris <- readLines(f, warn = FALSE)
  baris <- baris[!grepl("^\\s*#", baris) & grepl(":", baris)]
  kunci <- trimws(sub(":.*$", "", baris))
  nilai <- trimws(sub("^[^:]*:", "", baris))
  res <- as.list(nilai)
  names(res) <- kunci
  res
}

# Banner peringatan untuk berkas terkelola, sesuai gaya komentar.
.banner_terkelola <- function(gaya = c("tex", "r", "qmd")) {
  gaya <- match.arg(gaya)
  teks <- c(
    "BERKAS INI DIKELOLA OLEH PAKET skripsistis.",
    paste0("Disegarkan otomatis dari paket (versi ", .versi_paket(),
           ") saat render atau perbarui_template()."),
    "JANGAN diedit di sini - perubahan akan ditimpa.",
    "Tulis kustomisasi di tex/preamble-tambahan.tex (untuk preamble)."
  )
  pre <- switch(gaya, tex = "% ", r = "# ", qmd = "")
  if (identical(gaya, "qmd")) {
    c("<!--", paste0("  ", teks), "-->", "")
  } else {
    c(paste0(pre, strrep("=", 60)),
      paste0(pre, teks),
      paste0(pre, strrep("=", 60)), "")
  }
}

# Daftar berkas terkelola + cara memprosesnya. `mode_singkatan` menentukan
# apakah scan_singkatan.R relevan dan isi blok glossaries pada preamble.
.berkas_terkelola <- function(mode_singkatan) {
  daftar <- list(
    list(rel = "tex/preamble.tex", proses = "preamble", gaya = "tex"),
    list(rel = "apa-stis-id.csl",  proses = "salin",    gaya = NA),
    list(rel = "referensi-perintah.qmd", proses = "salin", gaya = NA)
  )
  if (identical(mode_singkatan, "glossaries")) {
    daftar <- c(daftar,
      list(list(rel = "scan_singkatan.R", proses = "salin", gaya = "r")))
  }
  daftar
}

# Hasilkan ISI baru sebuah berkas terkelola dari template paket.
.isi_terkelola <- function(spek, mode_singkatan) {
  template <- .lokasi_template()
  src <- file.path(template, spek$rel)
  if (!file.exists(src)) return(NULL)
  isi <- readLines(src, warn = FALSE)
  if (identical(spek$proses, "preamble")) {
    blok <- if (identical(mode_singkatan, "glossaries")) {
      .preamble_gls_aktif()
    } else {
      .preamble_gls_fallback()
    }
    isi <- gsub("{{GLOSSARIES_PREAMBLE}}", blok, isi, fixed = TRUE)
  }
  # Normalkan: pecah baris yang mengandung newline tertanam (mis. blok
  # GLOSSARIES multi-baris) agar setara dengan hasil readLines (idempoten).
  isi <- unlist(strsplit(paste(isi, collapse = "\n"), "\n", fixed = TRUE))
  if (!is.na(spek$gaya)) isi <- c(.banner_terkelola(spek$gaya), isi)
  isi
}

#' Perbarui berkas infrastruktur dari paket (tanpa menyusun ulang skripsi)
#'
#' Menyegarkan berkas yang DIKELOLA paket (preamble, CSL, pemindai singkatan,
#' rujukan perintah) pada sebuah proyek skripsi agar memakai versi terbaru dari
#' paket terpasang. Isi skripsi (folder `bab/`, `referensi.bib`, `singkatan.csv`,
#' `img/`, `index.qmd`, `_quarto.yml`, `tex/00_frontmatter.tex`, dan
#' `tex/preamble-tambahan.tex`) TIDAK disentuh.
#'
#' Alur tipikal: mahasiswa cukup memperbarui paket
#' (`remotes::install_github(...)` atau `install.packages(...)`) lalu menjalankan
#' `render_skripsi()` (yang memanggil fungsi ini otomatis) - perbaikan format
#' langsung berlaku tanpa membuat ulang proyek.
#'
#' @param path Direktori proyek skripsi.
#' @param backup Bila `TRUE` (default), berkas lama yang berubah dicadangkan ke
#'   `<nama>.bak` sebelum ditimpa.
#' @param diam Bila `TRUE`, tidak mencetak pesan (dipakai internal saat render).
#' @return (Secara *invisible*) vektor berkas yang diperbarui.
#' @export
perbarui_template <- function(path = ".", backup = TRUE, diam = FALSE) {
  if (!dir.exists(path)) stop("Direktori tidak ditemukan: ", path, call. = FALSE)
  konfig <- .baca_konfig(path)
  mode_singkatan <- if (!is.null(konfig$singkatan)) konfig$singkatan else "tidak"

  diubah <- character(0)
  for (spek in .berkas_terkelola(mode_singkatan)) {
    dst <- file.path(path, spek$rel)
    baru <- .isi_terkelola(spek, mode_singkatan)
    if (is.null(baru)) next
    lama <- if (file.exists(dst)) readLines(dst, warn = FALSE) else character(0)
    if (identical(lama, baru)) next
    dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
    if (isTRUE(backup) && length(lama)) {
      writeLines(lama, paste0(dst, ".bak"))
    }
    writeLines(baru, dst)
    diubah <- c(diubah, spek$rel)
  }

  # Catat versi paket terakhir yang dipakai.
  if (!is.null(konfig)) {
    .tulis_konfig(path,
                  peminatan     = konfig$peminatan %||% "",
                  jenis_skripsi = konfig$jenis_skripsi %||% "",
                  mode_singkatan = mode_singkatan)
  }

  if (!diam) {
    if (length(diubah)) {
      message("Berkas terkelola diperbarui ke versi ", .versi_paket(), ":")
      for (b in diubah) message("  - ", b)
      if (isTRUE(backup)) message("Cadangan lama disimpan dengan akhiran .bak")
    } else {
      message("Berkas terkelola sudah mutakhir (versi ", .versi_paket(), ").")
    }
  }
  invisible(diubah)
}

`%||%` <- function(a, b) if (is.null(a) || !nzchar(a)) b else a
