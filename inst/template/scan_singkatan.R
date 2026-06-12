#!/usr/bin/env Rscript
# ============================================================================
# Pemindai entri Daftar Singkatan & Daftar Simbol (mode glossaries).
# Dijalankan OTOMATIS oleh Quarto sebelum render (pre-render). Menggabungkan:
#   1) Daftar pusat : singkatan.csv (kolom: kunci,tipe,nama,keterangan; tipe =
#                     "singkatan" atau "simbol". Juga menerima 3 kolom
#                     kunci,nama,keterangan -> tipe="singkatan", atau 2 kolom
#                     nama,keterangan -> kunci diturunkan).
#   2) Dari teks     : \istilah{...} -> Daftar Singkatan,
#                      \simbol{...}  -> Daftar Simbol (\lambang = alias \simbol).
# Hasil ditulis ke tex/singkatan-entries.tex (dimuat di preamble) dengan
# type={singkatan|lambang}. Bila kunci sama di kedua sumber, DAFTAR PUSAT
# (singkatan.csv) diutamakan -> tanpa konflik antar-metode.
# ============================================================================

.slug <- function(x) {
  s <- tolower(as.character(x)); s <- gsub("\\\\[a-zA-Z]+", "", s)
  s <- gsub("[^a-z0-9]+", "", s)
  kosong <- !nzchar(s); s[kosong] <- paste0("istilah", seq_along(s))[kosong]
  make.unique(s, sep = "")
}
.tipe_baku <- function(x) ifelse(tolower(trimws(x)) %in% c("simbol","lambang","symbol"),
                                 "simbol", "singkatan")

.baca_args <- function(ch, mulai, n = 3L) {
  i <- mulai; L <- length(ch); args <- character(0)
  for (a in seq_len(n)) {
    while (i <= L && ch[i] %in% c(" ", "\t", "\n")) i <- i + 1L
    if (i > L || ch[i] != "{") return(NULL)
    depth <- 0L; buf <- character(0)
    repeat {
      if (i > L) return(NULL)
      c1 <- ch[i]
      if (c1 == "{") { depth <- depth + 1L; if (depth > 1L) buf <- c(buf, c1) }
      else if (c1 == "}") { depth <- depth - 1L; if (depth == 0L) { i <- i + 1L; break }; buf <- c(buf, c1) }
      else buf <- c(buf, c1)
      i <- i + 1L
    }
    args <- c(args, paste(buf, collapse = ""))
  }
  list(args = args, akhir = i)
}

.scan_makro <- function(teks, makro, tipe) {
  ch <- strsplit(teks, "", fixed = TRUE)[[1]]
  pos <- gregexpr(paste0("\\\\", makro, "(?![a-zA-Z])"), teks, perl = TRUE)[[1]]
  if (length(pos) == 1L && pos[1] == -1L) return(NULL)
  out <- list()
  for (p in pos) {
    r <- .baca_args(ch, p + nchar(makro) + 1L, 3L)
    if (!is.null(r)) out[[length(out)+1L]] <-
      data.frame(kunci = r$args[1], tipe = tipe, nama = r$args[2],
                 keterangan = r$args[3], stringsAsFactors = FALSE)
  }
  if (!length(out)) NULL else do.call(rbind, out)
}

# --- 1) Daftar pusat (CSV) ---
pusat <- NULL
if (file.exists("singkatan.csv")) {
  d <- utils::read.csv("singkatan.csv", stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8", check.names = FALSE)
  nm <- tolower(names(d))
  if (all(c("kunci","tipe","nama","keterangan") %in% nm)) {
    pusat <- data.frame(kunci = as.character(d[[which(nm=="kunci")]]),
                        tipe  = .tipe_baku(d[[which(nm=="tipe")]]),
                        nama  = as.character(d[[which(nm=="nama")]]),
                        keterangan = as.character(d[[which(nm=="keterangan")]]),
                        stringsAsFactors = FALSE)
  } else if (ncol(d) >= 4L) {
    pusat <- data.frame(kunci=as.character(d[[1]]), tipe=.tipe_baku(d[[2]]),
                        nama=as.character(d[[3]]), keterangan=as.character(d[[4]]),
                        stringsAsFactors = FALSE)
  } else if (ncol(d) == 3L) {
    pusat <- data.frame(kunci=as.character(d[[1]]), tipe="singkatan",
                        nama=as.character(d[[2]]), keterangan=as.character(d[[3]]),
                        stringsAsFactors = FALSE)
  } else if (ncol(d) == 2L) {
    pusat <- data.frame(kunci=.slug(d[[1]]), tipe="singkatan",
                        nama=as.character(d[[1]]), keterangan=as.character(d[[2]]),
                        stringsAsFactors = FALSE)
  }
}

# --- 2) Dari teks (*.qmd): \istilah -> singkatan, \lambang -> lambang ---
berkas <- c("index.qmd", list.files("bab", pattern = "\\.qmd$", full.names = TRUE))
teks_df <- NULL
for (f in berkas) {
  if (!file.exists(f)) next
  t <- paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  # Abaikan kode: hapus blok berpagar (```...```) dan kode sebaris (`...`) agar
  # contoh \istilah/\lambang di dalam kode tidak ikut terbaca.
  t <- gsub("(?s)```.*?```", "", t, perl = TRUE)
  t <- gsub("`[^`]*`", "", t)
  teks_df <- rbind(teks_df, .scan_makro(t, "istilah", "singkatan"),
                            .scan_makro(t, "simbol", "simbol"),
                            .scan_makro(t, "lambang", "simbol"))
}

# --- Gabung: pusat diutamakan; entri teks ditambah bila kunci belum ada ---
semua <- pusat
if (!is.null(teks_df)) {
  teks_df <- teks_df[!duplicated(teks_df$kunci), , drop = FALSE]
  tambah  <- teks_df[!(teks_df$kunci %in% semua$kunci), , drop = FALSE]
  semua   <- rbind(semua, tambah)
}
if (is.null(semua)) semua <- data.frame(kunci=character(0), tipe=character(0),
                                        nama=character(0), keterangan=character(0))

# --- Tulis berkas entri (dimuat preamble) ---
dir.create("tex", showWarnings = FALSE, recursive = TRUE)
baris <- sprintf("\\newglossaryentry{%s}{type={%s},name={%s},description={%s},sort={%s}}",
                 semua$kunci, semua$tipe, semua$nama, semua$keterangan, semua$kunci)
writeLines(c(
  "% BERKAS OTOMATIS - dibuat oleh scan_singkatan.R (pre-render). Jangan disunting manual.",
  "% Sumber: singkatan.csv (pusat) + \\istilah{...}/\\lambang{...} pada *.qmd (teks).",
  baris
), "tex/singkatan-entries.tex", useBytes = TRUE)
cat(sprintf("[scan_singkatan] %d entri (singkatan=%d, simbol=%d)\n",
            nrow(semua), sum(semua$tipe=="singkatan"), sum(semua$tipe=="simbol")))
