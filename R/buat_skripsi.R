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
#' @param jenis_skripsi Jenis/struktur skripsi yang menentukan kerangka bab,
#'   terlepas dari peminatan: `"Analisis"` (Bab I–V: Pendahuluan, Tinjauan
#'   Pustaka, Metode, Hasil dan Pembahasan, Kesimpulan) atau `"Pengembangan
#'   Sistem"` (Bab I–VI: Pendahuluan, Tinjauan Pustaka, Metode, Analisis dan
#'   Perancangan, Implementasi dan Evaluasi, Kesimpulan). Bila `NULL` (default),
#'   jenis disesuaikan otomatis dengan `peminatan` (Sains Data → "Analisis";
#'   Sistem Informasi Statistik → "Pengembangan Sistem"). Dengan parameter ini,
#'   mahasiswa Sains Data dapat menulis skripsi bertipe pengembangan sistem dan
#'   sebaliknya.
#' @param pembimbing,nip_pembimbing Nama dan NIP dosen pembimbing.
#' @param penguji1,nip_penguji1 Nama dan NIP Penguji I.
#' @param penguji2,nip_penguji2 Nama dan NIP Penguji II.
#' @param ketua_prodi,nip_ketua_prodi Nama dan NIP Ketua Program Studi.
#' @param tahun Tahun (default tahun berjalan).
#' @param daftar_singkatan Menyertakan elemen opsional **Daftar Singkatan** dan
#'   **Daftar Simbol** (setelah Daftar Lampiran). Nilai: `FALSE` (default),
#'   `TRUE`/`"csv"` (dua tabel statis dari `singkatan.csv`), atau `"glossaries"`
#'   (memakai paket `glossaries`: istilah muncul **otomatis** hanya bila dipakai
#'   di teks; entri dapat berasal dari `singkatan.csv` maupun ditulis langsung di
#'   teks dengan `\\istilah{kunci}{nama}{ket}` -> Daftar Singkatan, atau
#'   `\\simbol{kunci}{nama}{ket}` -> Daftar Simbol; rujuk dengan `\\gls{kunci}`).
#'   Pemisahan singkatan vs simbol memakai kolom `tipe` (nilai `singkatan`/
#'   `simbol`). Pedoman KS 2025 tidak mewajibkan elemen ini.
#' @param singkatan Isi awal (opsional). `data.frame` (kolom `kunci,tipe,nama,
#'   keterangan`; atau `nama,keterangan`), matriks, atau vektor karakter bernama
#'   (nama = singkatan/simbol, nilai = keterangan). Tanpa `tipe`, entri dianggap
#'   singkatan. Bila `NULL`, dipakai contoh `singkatan.csv` bawaan. Pada mode
#'   `"glossaries"`, pemindai pra-render (`scan_singkatan.R`) menggabungkan sumber
#'   ini dengan definisi di teks; bila kunci sama, sumber pusat diutamakan.
#' @param overwrite Bila `TRUE`, menimpa direktori yang sudah ada.
#' @param render Bila `TRUE`, langsung menjalankan `quarto render` setelah membuat
#'   proyek (membutuhkan Quarto terpasang).
#'
#' @return (Secara *invisible*) path absolut proyek yang dibuat.
#' @export
#'
#' @examples
#' \dontrun{
#' # Skripsi analisis (default untuk Sains Data)
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
#'
#' # Mahasiswa Sains Data menulis skripsi PENGEMBANGAN SISTEM
#' buat_skripsi(
#'   path          = "skripsi-sd-sistem",
#'   judul         = "Pengembangan Dasbor Monitoring Kemiskinan Berbasis Web",
#'   nama          = "Nama Mahasiswa",
#'   nim           = "222212501",
#'   peminatan     = "Sains Data",
#'   jenis_skripsi = "Pengembangan Sistem"
#' )
#' }
buat_skripsi <- function(
    path            = "skripsi-stis",
    judul           = "TULISKAN JUDUL SKRIPSI ANDA DI SINI",
    subjudul        = NULL,
    nama            = "NAMA MAHASISWA",
    nim             = "NIM",
    peminatan       = c("Sains Data", "Sistem Informasi Statistik"),
    jenis_skripsi   = NULL,
    pembimbing      = "Nama Dosen Pembimbing",
    nip_pembimbing  = "0000",
    penguji1        = "Nama Dosen Penguji I",
    nip_penguji1    = "0000",
    penguji2        = "Nama Dosen Penguji II",
    nip_penguji2    = "0000",
    ketua_prodi     = "Nama Ketua Program Studi",
    nip_ketua_prodi = "0000",
    tahun           = format(Sys.Date(), "%Y"),
    daftar_singkatan = FALSE,
    singkatan        = NULL,
    overwrite       = FALSE,
    render          = FALSE) {

  peminatan <- match.arg(peminatan)
  peminatan_str <- if (identical(peminatan, "Sains Data")) {
    "SAINS DATA"
  } else {
    "SISTEM INFORMASI STATISTIK"
  }

  # --- Tentukan jenis/struktur skripsi (terpisah dari peminatan) ---
  #     Bila tidak ditentukan, ikuti default berdasarkan peminatan, tetapi
  #     mahasiswa boleh memilih jenis lain (mis. Sains Data menulis skripsi
  #     pengembangan sistem, atau sebaliknya).
  if (is.null(jenis_skripsi)) {
    jenis_skripsi <- if (identical(peminatan, "Sistem Informasi Statistik")) {
      "Pengembangan Sistem"
    } else {
      "Analisis"
    }
  }
  jenis_skripsi <- match.arg(
    jenis_skripsi,
    c("Analisis", "Pengembangan Sistem")
  )

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

  # --- Pilih kerangka bab sesuai JENIS skripsi (bukan peminatan) ---
  #     Analisis            : Bab I-V (Pendahuluan, Tinjauan Pustaka,
  #                           Metode, Hasil dan Pembahasan, Kesimpulan).
  #     Pengembangan Sistem : Bab I-VI (Pendahuluan, Tinjauan Pustaka,
  #                           Metode, Analisis dan Perancangan,
  #                           Implementasi dan Evaluasi, Kesimpulan).
  bab_dir <- file.path(path, "bab")
  if (identical(jenis_skripsi, "Pengembangan Sistem")) {
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

  # --- Elemen opsional: Daftar Singkatan dan Daftar Simbol ---
  #     Pedoman KS 2025 tidak mewajibkan elemen ini (OPSIONAL, default nonaktif),
  #     ditempatkan setelah Daftar Lampiran. Dua mode:
  #       "csv"        : tabel dua kolom; isi dibaca dari singkatan.csv (manual).
  #       "glossaries" : memakai paket glossaries (\makenoidxglossaries); HANYA
  #                      istilah yang dipakai di teks lewat \gls{...} yang muncul,
  #                      terurut otomatis. Entri di tex/singkatan-entries.tex.
  mode_singkatan <- if (isFALSE(daftar_singkatan) || is.null(daftar_singkatan)) {
    "tidak"
  } else if (isTRUE(daftar_singkatan)) {
    "csv"
  } else {
    match.arg(as.character(daftar_singkatan)[1], c("csv", "glossaries"))
  }

  f_qmd_csv <- file.path(bab_dir, "daftar-singkatan.qmd")
  f_qmd_gls <- file.path(bab_dir, "daftar-singkatan-gls.qmd")
  f_csv     <- file.path(path, "singkatan.csv")
  f_entries <- file.path(path, "tex", "singkatan-entries.tex")
  f_scan    <- file.path(path, "scan_singkatan.R")
  .buang <- function(f) if (file.exists(f)) unlink(f, force = TRUE)
  prerender_singkatan <- ""

  if (identical(mode_singkatan, "csv")) {
    if (!is.null(singkatan)) .tulis_singkatan_csv(singkatan, f_csv)
    .buang(f_qmd_gls); .buang(f_entries); .buang(f_scan)
    include_singkatan   <- "{{< include bab/daftar-singkatan.qmd >}}"
    glossaries_preamble <- .preamble_gls_fallback()
  } else if (identical(mode_singkatan, "glossaries")) {
    if (!is.null(singkatan)) .tulis_singkatan_csv(singkatan, f_csv)
    .buang(f_qmd_csv)
    .sisipkan_contoh_gls(file.path(bab_dir, "bab1_pendahuluan.qmd"))
    # Cadangan entri dari CSV (akan ditimpa scan_singkatan.R saat render).
    tryCatch(.tulis_entries_dari_csv(f_csv, f_entries), error = function(e) NULL)
    include_singkatan   <- "{{< include bab/daftar-singkatan-gls.qmd >}}"
    glossaries_preamble <- .preamble_gls_aktif()
    prerender_singkatan <- "  pre-render:\n    - scan_singkatan.R"
  } else {
    .buang(f_qmd_csv); .buang(f_qmd_gls); .buang(f_csv); .buang(f_entries); .buang(f_scan)
    include_singkatan   <- ""
    glossaries_preamble <- .preamble_gls_fallback()
  }

  # --- Sistematika Penulisan (jumlah & nama bab sesuai JENIS skripsi) ---
  #     Disisipkan ke bab1_pendahuluan.qmd (token {{SISTEMATIKA_PENULISAN}}) agar
  #     prosa benar untuk kedua jenis: Analisis (5 bab) & Pengembangan Sistem (6 bab).
  sistematika <- if (identical(jenis_skripsi, "Pengembangan Sistem")) {
    paste0(
      "Penulisan skripsi ini terdiri atas enam bab. Bab I Pendahuluan menguraikan ",
      "latar belakang, identifikasi dan batasan masalah, tujuan, manfaat, serta ",
      "sistematika penulisan. Bab II Tinjauan Pustaka memuat landasan teori dan ",
      "penelitian terkait. Bab III Metode Penelitian menjelaskan data, tahapan, dan ",
      "teknik yang digunakan. Bab IV Analisis dan Perancangan menyajikan analisis ",
      "kebutuhan serta rancangan sistem. Bab V Implementasi dan Evaluasi memaparkan ",
      "implementasi sistem dan hasil pengujiannya. Bab VI Kesimpulan dan Saran berisi ",
      "kesimpulan penelitian dan saran untuk pengembangan selanjutnya."
    )
  } else {
    paste0(
      "Penulisan skripsi ini terdiri atas lima bab. Bab I Pendahuluan menguraikan ",
      "latar belakang, identifikasi dan batasan masalah, tujuan, manfaat, serta ",
      "sistematika penulisan. Bab II Tinjauan Pustaka memuat landasan teori dan ",
      "penelitian terkait. Bab III Metode Penelitian menjelaskan data, tahapan, dan ",
      "teknik analisis yang digunakan. Bab IV Hasil dan Pembahasan menyajikan temuan ",
      "penelitian beserta pembahasannya. Bab V Kesimpulan dan Saran berisi kesimpulan ",
      "penelitian dan saran untuk penelitian selanjutnya."
    )
  }

  # --- Susun peta substitusi token ---
  peta <- c(
    list(
      JUDUL           = judul,
      SISTEMATIKA_PENULISAN = sistematika,
      INCLUDE_SINGKATAN   = include_singkatan,
      GLOSSARIES_PREAMBLE = glossaries_preamble,
      PRERENDER_SINGKATAN = prerender_singkatan,
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

  # --- Konfigurasi + berkas terkelola (untuk pembaruan tanpa menyusun ulang) ---
  .tulis_konfig(path, peminatan = peminatan, jenis_skripsi = jenis_skripsi,
                mode_singkatan = mode_singkatan)
  f_tambahan <- file.path(path, "tex", "preamble-tambahan.tex")
  if (!file.exists(f_tambahan)) {
    writeLines(c(
      "% ------------------------------------------------------------",
      "% Kustomisasi LaTeX milik Anda (paket / perintah tambahan).",
      "% Berkas ini TIDAK ditimpa saat pembaruan paket.",
      "% Contoh:  \\usepackage{namapaket}",
      "% ------------------------------------------------------------"
    ), f_tambahan)
  }
  # Segarkan berkas terkelola sekaligus menstempel banner (idempoten).
  perbarui_template(path, backup = FALSE, diam = TRUE)

  abs_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  message("Proyek skripsi STIS dibuat di: ", abs_path)
  message("Peminatan: ", peminatan, " | Jenis skripsi: ", jenis_skripsi)
  message("Render dengan: quarto render \"", abs_path, "\"")

  if (isTRUE(render)) {
    render_skripsi(abs_path)
  }

  invisible(abs_path)
}

#' Render proyek skripsi menggunakan Quarto
#'
#' Pembungkus untuk menjalankan `quarto render` pada direktori proyek. Sebelum
#' render, berkas infrastruktur yang DIKELOLA paket (preamble, CSL, dll.)
#' otomatis disegarkan dari paket terpasang (lihat [perbarui_template()]),
#' sehingga perbaikan format cukup dilakukan dengan memperbarui paket.
#'
#' @param path Direktori proyek skripsi.
#' @param perbarui Bila `TRUE` (default), segarkan berkas terkelola dari paket
#'   sebelum render. Set `FALSE` untuk render apa adanya.
#' @return (Secara *invisible*) `path`.
#' @export
render_skripsi <- function(path = ".", perbarui = TRUE) {
  if (isTRUE(perbarui) && file.exists(file.path(path, "_skripsistis.yml"))) {
    # Segarkan berkas terkelola dari paket terpasang sebelum render, sehingga
    # perbaikan format pada paket langsung berlaku tanpa menyusun ulang skripsi.
    tryCatch(perbarui_template(path, backup = FALSE, diam = TRUE),
             error = function(e) warning("Gagal menyegarkan berkas terkelola: ",
                                         conditionMessage(e), call. = FALSE))
  }
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
