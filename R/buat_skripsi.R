#' Buat proyek Quarto skripsi Politeknik Statistika STIS
#'
#' Menyalin kerangka (template) proyek Quarto skripsi STIS ke direktori baru dan
#' mengisi metadata (judul, nama, NIM, pembimbing, penguji, dan lain-lain) secara
#' otomatis. Gaya kutipan dan daftar pustaka mengikuti **APA edisi ke-7 dengan
#' modifikasi bahasa Indonesia** (penghubung "dan", singkatan "dkk.", "t.t.",
#' "ed. ke-N", "Penerj.").
#'
#' @param path Direktori tujuan proyek (akan dibuat). Default `"skripsi-stis"`.
#' @param judul Judul skripsi (tanpa subjudul).
#' @param subjudul Subjudul skripsi (opsional, `NULL` jika tidak ada).
#' @param nama Nama mahasiswa.
#' @param nim Nomor Induk Mahasiswa.
#' @param peminatan Peminatan: `"Sains Data"` atau `"Sistem Informasi Statistik"`.
#' @param pembimbing,nip_pembimbing Nama dan NIP dosen pembimbing.
#' @param penguji1,nip_penguji1 Nama dan NIP Penguji I.
#' @param penguji2,nip_penguji2 Nama dan NIP Penguji II.
#' @param ketua_prodi,nip_ketua_prodi Nama dan NIP Ketua Program Studi.
#' @param tahun Tahun (default tahun berjalan).
#' @param overwrite Bila `TRUE`, menimpa direktori yang sudah ada.
#' @param render Bila `TRUE`, langsung menjalankan `quarto render` setelah membuat
#'   proyek (membutuhkan Quarto terpasang).
#'
#' @return (Secara *invisible*) path absolut proyek yang dibuat.
#' @export
#'
#' @examples
#' \dontrun{
#' buat_skripsi(
#'   path        = "skripsi-saya",
#'   judul       = "Pemodelan PMT Berbasis GPBoost di Provinsi Jawa Timur",
#'   nama        = "Nama Mahasiswa",
#'   nim         = "222212501",
#'   peminatan   = "Sains Data",
#'   ketua_prodi = "Nama Ketua Program Studi",
#'   pembimbing  = "Nama Pembimbing",
#'   render      = TRUE
#' )
#' }
buat_skripsi <- function(
    path            = "skripsi-stis",
    judul           = "TULISKAN JUDUL SKRIPSI ANDA DI SINI",
    subjudul        = NULL,
    nama            = "NAMA MAHASISWA",
    nim             = "NIM",
    peminatan       = c("Sains Data", "Sistem Informasi Statistik"),
    pembimbing      = "Nama Dosen Pembimbing",
    nip_pembimbing  = "0000",
    penguji1        = "Nama Dosen Penguji I",
    nip_penguji1    = "0000",
    penguji2        = "Nama Dosen Penguji II",
    nip_penguji2    = "0000",
    ketua_prodi     = "Nama Ketua Program Studi",
    nip_ketua_prodi = "0000",
    tahun           = format(Sys.Date(), "%Y"),
    overwrite       = FALSE,
    render          = FALSE) {

  peminatan <- match.arg(peminatan)
  peminatan_str <- if (identical(peminatan, "Sains Data")) {
    "SAINS DATA"
  } else {
    "SISTEM INFORMASI STATISTIK"
  }

  # --- Validasi direktori tujuan ---
  if (dir.exists(path)) {
    if (!overwrite) {
      stop(
        "Direktori '", path, "' sudah ada. ",
        "Gunakan overwrite = TRUE untuk menimpanya.",
        call. = FALSE
      )
    }
    unlink(path, recursive = TRUE, force = TRUE)
  }

  template <- .lokasi_template()
  if (!nzchar(template) || !dir.exists(template)) {
    stop("Template bawaan tidak ditemukan. Pastikan paket terpasang dengan benar.",
         call. = FALSE)
  }

  # --- Salin seluruh template ke tujuan ---
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  berkas_template <- list.files(template, recursive = TRUE, full.names = FALSE,
                                all.files = TRUE, no.. = TRUE)
  for (rel in berkas_template) {
    src <- file.path(template, rel)
    dst <- file.path(path, rel)
    dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
    file.copy(src, dst, overwrite = TRUE)
  }

  # --- Pilih kerangka bab sesuai peminatan ---
  #     Sains Data                : Bab I-V (Pendahuluan, Tinjauan Pustaka,
  #                                 Metode, Hasil dan Pembahasan, Kesimpulan).
  #     Sistem Informasi Statistik: Bab I-VI (Pendahuluan, Tinjauan Pustaka,
  #                                 Metode, Analisis dan Perancangan,
  #                                 Implementasi dan Evaluasi, Kesimpulan).
  bab_dir <- file.path(path, "bab")
  if (identical(peminatan, "Sistem Informasi Statistik")) {
    urutan_bab <- c("bab1_pendahuluan", "bab2_tinjauan_pustaka",
                    "bab3_metode_si", "bab4_analisis", "bab5_implementasi",
                    "bab5_kesimpulan")
    bab_dibuang <- c("bab3_metode.qmd", "bab4_hasil.qmd")
  } else {
    urutan_bab <- c("bab1_pendahuluan", "bab2_tinjauan_pustaka",
                    "bab3_metode", "bab4_hasil", "bab5_kesimpulan")
    bab_dibuang <- c("bab3_metode_si.qmd", "bab4_analisis.qmd",
                     "bab5_implementasi.qmd")
  }
  # Hapus berkas bab yang tidak dipakai peminatan terpilih
  for (b in bab_dibuang) {
    f <- file.path(bab_dir, b)
    if (file.exists(f)) unlink(f, force = TRUE)
  }
  # Susun daftar include untuk index.qmd
  include_bab <- paste(
    sprintf("{{< include bab/%s.qmd >}}", urutan_bab),
    collapse = "\n\n"
  )

  # --- Susun peta substitusi token ---
  peta <- c(
    list(
      JUDUL           = judul,
      NAMA            = nama,
      NAMA_KAPITAL    = toupper(nama),
      NIM             = nim,
      PEMINATAN       = peminatan_str,
      PEMBIMBING      = pembimbing,
      NIP_PEMBIMBING  = nip_pembimbing,
      PENGUJI1        = penguji1,
      NIP_PENGUJI1    = nip_penguji1,
      PENGUJI2        = penguji2,
      NIP_PENGUJI2    = nip_penguji2,
      KETUA_PRODI     = ketua_prodi,
      NIP_KETUA_PRODI = nip_ketua_prodi,
      TAHUN           = as.character(tahun),
      INCLUDE_BAB     = include_bab
    ),
    .blok_subjudul(subjudul)
  )

  .substitusi_berkas(path, peta)

  abs_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  message("Proyek skripsi STIS dibuat di: ", abs_path)
  message("Render dengan: quarto render \"", abs_path, "\"")

  if (isTRUE(render)) {
    render_skripsi(abs_path)
  }

  invisible(abs_path)
}

#' Render proyek skripsi menggunakan Quarto
#'
#' Pembungkus tipis untuk menjalankan `quarto render` pada direktori proyek.
#'
#' @param path Direktori proyek skripsi.
#' @return (Secara *invisible*) `path`.
#' @export
render_skripsi <- function(path = ".") {
  quarto <- Sys.which("quarto")
  if (!nzchar(quarto)) {
    stop("Perintah 'quarto' tidak ditemukan pada PATH. Pasang Quarto terlebih dahulu: ",
         "https://quarto.org/docs/get-started/", call. = FALSE)
  }
  status <- system2(quarto, c("render", shQuote(normalizePath(path))))
  if (!identical(status, 0L)) {
    warning("quarto render selesai dengan status non-nol: ", status, call. = FALSE)
  }
  invisible(path)
}

#' Path berkas CSL APA 7 modifikasi bahasa Indonesia
#'
#' Mengembalikan path ke berkas gaya sitasi `apa-stis-id.csl` yang disertakan
#' dalam paket, untuk dipakai mandiri (misalnya pada dokumen R Markdown/Quarto
#' lain di luar template skripsi).
#'
#' @return Path absolut berkas CSL (karakter).
#' @export
#' @examples
#' path_csl()
path_csl <- function() {
  system.file("csl", "apa-stis-id.csl", package = "skripsistis")
}
