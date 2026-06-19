# Utilitas internal (tidak diekspor) ------------------------------------------

#' Lokasi folder template bawaan paket
#' @noRd
.lokasi_template <- function() {
  system.file("template", package = "skripsistis")
}

#' Ganti token {{KEY}} pada sebuah string dengan nilai dari daftar
#' @noRd
.ganti_token <- function(teks, peta) {
  for (kunci in names(peta)) {
    pola <- paste0("{{", kunci, "}}")
    teks <- gsub(pola, peta[[kunci]], teks, fixed = TRUE)
  }
  teks
}

#' Terapkan substitusi token ke seluruh berkas teks dalam direktori
#' @noRd
.substitusi_berkas <- function(dir, peta) {
  ext_teks <- c("qmd", "yml", "yaml", "tex", "bib", "md", "txt")
  berkas <- list.files(dir, recursive = TRUE, full.names = TRUE)
  for (f in berkas) {
    if (tolower(tools::file_ext(f)) %in% ext_teks) {
      isi <- tryCatch(
        readLines(f, warn = FALSE, encoding = "UTF-8"),
        error = function(e) NULL
      )
      if (is.null(isi)) next
      baru <- .ganti_token(isi, peta)
      if (!identical(isi, baru)) {
        con <- file(f, open = "w", encoding = "UTF-8")
        writeLines(baru, con)
        close(con)
      }
    }
  }
  invisible(TRUE)
}

#' Bangun blok subjudul LaTeX bila subjudul disediakan
#' @noRd
.blok_subjudul <- function(subjudul) {
  if (is.null(subjudul) || !nzchar(subjudul)) {
    list(
      SUBJUDUL            = "",
      SUBJUDUL_BLOCK      = "",
      SUBJUDUL_PERNYATAAN = "",
      SUBJUDUL_PENGESAHAN = ""
    )
  } else {
    list(
      SUBJUDUL            = subjudul,
      SUBJUDUL_BLOCK      = sprintf("\\par\\vspace{\\spasi}{\\bfseries\\fontsize{14}{21}\\selectfont (%s)\\par}", subjudul),
      SUBJUDUL_PERNYATAAN = sprintf("{\\bfseries (%s)\\par}", subjudul),
      SUBJUDUL_PENGESAHAN = sprintf("\\begin{center}{\\bfseries\\large (%s)}\\end{center}", subjudul)
    )
  }
}

#' Tulis data singkatan ke singkatan.csv (untuk Daftar Singkatan dan Simbol)
#'
#' Menerima `singkatan` berupa data.frame (>= 2 kolom), matriks 2 kolom, atau
#' vektor karakter bernama (nama = singkatan/simbol, nilai = keterangan).
#' @noRd
.tulis_singkatan_csv <- function(singkatan, path_csv) {
  df <- .normalisasi_singkatan(singkatan)
  out <- data.frame(kunci = df$kunci, tipe = df$tipe, nama = df$nama,
                    keterangan = df$keterangan, stringsAsFactors = FALSE)
  utils::write.csv(out, path_csv, row.names = FALSE, fileEncoding = "UTF-8")
  invisible(path_csv)
}

#' Bakukan nilai tipe entri menjadi "singkatan" atau "simbol"
#' @noRd
.tipe_norm <- function(x) {
  ifelse(tolower(trimws(as.character(x))) %in% c("simbol", "lambang", "symbol"),
         "simbol", "singkatan")
}

#' Normalisasi input singkatan menjadi data.frame(kunci, tipe, nama, keterangan)
#' @noRd
.normalisasi_singkatan <- function(singkatan) {
  if (is.matrix(singkatan)) singkatan <- as.data.frame(singkatan, stringsAsFactors = FALSE)
  if (is.character(singkatan) && !is.null(names(singkatan))) {
    return(data.frame(kunci = .slug_kunci(names(singkatan)), tipe = "singkatan",
                      nama = names(singkatan), keterangan = unname(singkatan),
                      stringsAsFactors = FALSE))
  }
  if (!is.data.frame(singkatan)) {
    stop("'singkatan' harus data.frame, matriks, atau vektor karakter bernama.",
         call. = FALSE)
  }
  nm <- tolower(names(singkatan)); idx <- function(c) which(nm == c)[1]
  if (all(c("nama", "keterangan") %in% nm)) {
    nama  <- as.character(singkatan[[idx("nama")]])
    ket   <- as.character(singkatan[[idx("keterangan")]])
    tipe  <- if ("tipe"  %in% nm) .tipe_norm(singkatan[[idx("tipe")]]) else "singkatan"
    kunci <- if ("kunci" %in% nm) as.character(singkatan[[idx("kunci")]]) else .slug_kunci(nama)
  } else {
    k <- ncol(singkatan)
    if (k >= 4L) {
      kunci <- as.character(singkatan[[1]]); tipe <- .tipe_norm(singkatan[[2]])
      nama  <- as.character(singkatan[[3]]); ket  <- as.character(singkatan[[4]])
    } else if (k == 3L) {
      kunci <- as.character(singkatan[[1]]); tipe <- "singkatan"
      nama  <- as.character(singkatan[[2]]); ket  <- as.character(singkatan[[3]])
    } else if (k == 2L) {
      nama  <- as.character(singkatan[[1]]); ket <- as.character(singkatan[[2]])
      kunci <- .slug_kunci(nama); tipe <- "singkatan"
    } else {
      stop("'singkatan' (data.frame) harus memiliki 2 sampai 4 kolom.", call. = FALSE)
    }
  }
  data.frame(kunci = kunci, tipe = rep(tipe, length.out = length(kunci)),
             nama = nama, keterangan = ket, stringsAsFactors = FALSE)
}

#' Turunkan kunci glossaries yang aman dari teks nama
#' @noRd
.slug_kunci <- function(x) {
  s <- tolower(as.character(x))
  s <- gsub("\\\\[a-zA-Z]+", "", s)          # buang perintah LaTeX (mis. \mu)
  s <- gsub("[^a-z0-9]+", "", s)             # sisakan alfanumerik
  kosong <- !nzchar(s)
  s[kosong] <- paste0("istilah", seq_along(s))[kosong]
  make.unique(s, sep = "")
}

#' Tulis entri glossaries (ber-type) ke tex dari singkatan.csv (cadangan scaffold)
#' @noRd
.tulis_entries_dari_csv <- function(path_csv, path_tex) {
  if (!file.exists(path_csv)) return(invisible())
  d <- utils::read.csv(path_csv, stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8", check.names = FALSE)
  df <- .normalisasi_singkatan(d)
  dir.create(dirname(path_tex), recursive = TRUE, showWarnings = FALSE)
  baris <- sprintf(
    "\\newglossaryentry{%s}{type={%s},name={%s},description={%s},sort={%s}}",
    df$kunci, df$tipe, df$nama, df$keterangan, df$kunci
  )
  writeLines(c(
    "% Cadangan dari singkatan.csv; ditimpa oleh scan_singkatan.R saat render.",
    baris
  ), path_tex, useBytes = TRUE)
  invisible(path_tex)
}

#' Blok preamble untuk mode glossaries aktif (dua daftar: singkatan & simbol)
#' @noRd
.preamble_gls_aktif <- function() {
  paste(
    "\\usepackage[nopostdot,nonumberlist,toc=false]{glossaries}",
    "\\newglossary*{singkatan}{Daftar Singkatan}",
    "\\newglossary*{simbol}{Daftar Simbol}",
    "\\makenoidxglossaries",
    "% Judul daftar dicetak manual via \\judulfrontmatter; matikan judul bawaan.",
    "\\renewcommand{\\glossarysection}[2][]{}",
    "% Gaya tabel dua kolom DENGAN header (berulang tiap halaman).",
    "\\newglossarystyle{gayasingkatan}{%",
    "  \\setglossarystyle{long}%",
    "  \\renewcommand*{\\glossaryheader}{\\textbf{Singkatan} & \\textbf{Keterangan}\\tabularnewline\\hline\\endhead}%",
    "}",
    "\\newglossarystyle{gayasimbol}{%",
    "  \\setglossarystyle{long}%",
    "  \\renewcommand*{\\glossaryheader}{\\textbf{Simbol} & \\textbf{Keterangan}\\tabularnewline\\hline\\endhead}%",
    "}",
    "% Definisi DARI TEKS: \\istilah -> Daftar Singkatan, \\simbol -> Daftar Simbol",
    "% (\\lambang dipertahankan sebagai alias \\simbol). Di dalam dokumen keduanya",
    "% hanya menampilkan istilah (\\gls); definisi entri diangkat ke preamble oleh",
    "% scan_singkatan.R (pre-render) sehingga tak ada konflik.",
    "\\newcommand{\\istilah}[3]{\\gls{#1}}",
    "\\newcommand{\\simbol}[3]{\\gls{#1}}",
    "\\newcommand{\\lambang}[3]{\\gls{#1}}",
    "\\IfFileExists{tex/singkatan-entries.tex}{\\loadglsentries{tex/singkatan-entries.tex}}{}",
    sep = "\n"
  )
}

#' Blok preamble jaring pengaman (mode non-glossaries)
#' @noRd
.preamble_gls_fallback <- function() {
  paste(
    "% Jaring pengaman: \\gls dkk. agar dokumen tetap kompilasi bila ada sisa",
    "% perintah glossaries meski modenya tidak aktif.",
    "\\providecommand{\\gls}[1]{#1}\\providecommand{\\Gls}[1]{#1}",
    "\\providecommand{\\glspl}[1]{#1}\\providecommand{\\Glspl}[1]{#1}",
    "\\providecommand{\\acrshort}[1]{#1}\\providecommand{\\acrlong}[1]{#1}",
    "\\providecommand{\\istilah}[3]{#2}\\providecommand{\\simbol}[3]{#2}\\providecommand{\\lambang}[3]{#2}",
    sep = "\n"
  )
}

#' Sisipkan contoh pemakaian \gls{} ke Bab I (mode glossaries)
#' @noRd
.sisipkan_contoh_gls <- function(bab1_qmd) {
  if (!file.exists(bab1_qmd)) return(invisible())
  contoh <- c(
    "",
    "::: {.callout-tip title=\"Petunjuk  -  Daftar Singkatan (mode glossaries)\" appearance=\"simple\"}",
    "Rujuk singkatan dengan `\\istilah{kunci}{nama}{keterangan}` (mis.",
    "`\\istilah{pmt}{PMT}{Proxy Means Test}`) dan simbol dengan",
    "`\\simbol{kunci}{nama}{keterangan}`. Keduanya cukup ditulis sekali; entri",
    "otomatis masuk daftar yang sesuai dan hanya muncul bila dipakai. Entri juga",
    "dapat ditaruh di **daftar pusat** `singkatan.csv` (bila kunci sama, pusat",
    "diutamakan -- tanpa konflik). **Hapus contoh kalimat di bawah dan kotak ini",
    "pada naskah final.**",
    ":::",
    "",
    "Sebagai contoh, lembaga \\gls{bps} dirujuk dari daftar pusat; istilah",
    "\\istilah{pmt}{PMT}{Proxy Means Test} dan simbol \\simbol{theta}{$\\theta$}{parameter model}",
    "didefinisikan langsung di teks.",
    ""
  )
  cat(paste(contoh, collapse = "\n"), file = bab1_qmd, append = TRUE)
  invisible()
}

# Keluaran LaTeX: inline (default) atau simpan ke berkas .tex agar dapat diedit.
#
# tex    : string kode LaTeX yang dihasilkan fungsi.
# simpan : NULL (kembalikan inline) atau path berkas .tex tujuan.
# timpa  : bila FALSE (default) dan berkas sudah ada, berkas TIDAK ditimpa
#          (editan mahasiswa dipertahankan); bila TRUE, berkas dibuat ulang.
# Saat 'simpan' diisi, fungsi menulis berkas lalu mengembalikan '\input{path}'
# sehingga render memakai berkas tersebut (termasuk editan manual).
.keluaran_latex <- function(tex, simpan = NULL, timpa = FALSE) {
  if (is.null(simpan)) {
    return(knitr::raw_latex(tex))
  }
  d <- dirname(simpan)
  if (!identical(d, ".") && !dir.exists(d)) {
    dir.create(d, showWarnings = FALSE, recursive = TRUE)
  }
  if (!file.exists(simpan) || isTRUE(timpa)) {
    writeLines(tex, simpan, useBytes = TRUE)
    if (interactive()) message(sprintf(
      "skripsistis: kode LaTeX disimpan ke '%s'. Edit berkas itu bila perlu; berkas di-input otomatis.",
      simpan))
  } else {
    if (interactive()) message(sprintf(
      "skripsistis: '%s' sudah ada -> memakai versi tersebut (editan dipertahankan). Pakai timpa = TRUE untuk membuat ulang.",
      simpan))
  }
  knitr::raw_latex(sprintf("\\input{%s}", simpan))
}
