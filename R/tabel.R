# Pembantu penyajian TABEL sesuai pedoman KS 2025.
#
# Logika kepatuhan pedoman dipusatkan di sini (bukan disalin ke tiap bab),
# sehingga perbaikan format tabel cukup lewat pembaruan paket + render ulang,
# tanpa menyusun ulang skripsi.

# Lolos-kan karakter khusus LaTeX pada teks biasa (judul kolom & sel data).
# Karakter math ($ \ { }) sengaja dibiarkan agar notasi seperti $\mu$ tetap bisa.
.lx_escape <- function(x) {
  x <- as.character(x)
  x <- gsub("&", "\\&", x, fixed = TRUE)
  x <- gsub("%", "\\%", x, fixed = TRUE)
  x <- gsub("#", "\\#", x, fixed = TRUE)
  x <- gsub("_", "\\_", x, fixed = TRUE)
  x
}

.align_default <- function(df) {
  # Kolom pertama rata kiri (label), sisanya rata kanan (angka) - lazim di pedoman.
  c("l", rep("r", max(ncol(df) - 1L, 0L)))
}

#' Tabel sesuai pedoman (non-float, grid, nomor kolom)
#'
#' Menyajikan sebuah `data.frame` sebagai tabel yang patuh Pedoman Penyusunan
#' Skripsi KS 2025: judul tabel di atas ("Tabel N. ..."), garis kolom penuh
#' (grid), baris **nomor kolom** `(1)(2)(3)...` yang rata tengah dengan garis
#' pemisah dari baris judul kolom, tanpa garis antar-baris data, serta baris
#' **Sumber**/**Keterangan** menyatu di bawah tabel. Tabel bersifat *non-float*
#' (tidak mengambang) sehingga muncul tepat pada posisi penulisan, dan berjarak
#' ~3 spasi dari teks sebelum/sesudahnya.
#'
#' Penomoran "Tabel N" serta entri Daftar Tabel dilakukan otomatis melalui
#' `\\captionof{table}`. Rujuk silang dengan `\\ref{label}`.
#'
#' @param df Data untuk badan tabel (`data.frame`/`matrix`). Nama kolom dipakai
#'   sebagai judul kolom.
#' @param judul Judul tabel (tanpa kata "Tabel N." dan tanpa titik akhir).
#' @param label Label LaTeX untuk rujuk silang, mis. `"tab:miskin"` (hindari
#'   awalan `tbl-`/`fig-` agar tidak ditangani ulang oleh Quarto).
#' @param sumber Teks sumber data (tanpa kata "Sumber:"). `NULL` (default) untuk
#'   data primer/olahan sendiri - baris sumber tidak ditampilkan.
#' @param ket Keterangan tambahan di bawah tabel (tanpa kata "Keterangan:").
#' @param align Vektor perataan kolom (`"l"`,`"c"`,`"r"`) sepanjang jumlah kolom.
#'   `NULL` (default): kolom pertama kiri, sisanya kanan.
#' @param nomor_kolom Tampilkan baris nomor kolom `(1)(2)...` (default `TRUE`).
#' @param garis_total Tambah garis di atas baris terakhir (mis. baris "Total").
#'   Default `FALSE`.
#' @param escape Lolos-kan karakter khusus LaTeX (`& % # _`) pada judul kolom &
#'   data. Default `TRUE`. Set `FALSE` bila Anda sengaja menulis LaTeX/math.
#'
#' @return Objek `knitr::raw_latex` siap dicetak dalam chunk R (PDF). Untuk
#'   keluaran non-LaTeX dikembalikan `knitr::kable` biasa.
#' @examples
#' \dontrun{
#' df <- data.frame(Daerah = c("Perkotaan","Perdesaan","Total"),
#'                  Jumlah = c("1.641,18","2.234,70","3.875,88"),
#'                  Persen = c("7,00","12,86","9,50"))
#' tabel_skripsi(df, "Jumlah dan persentase penduduk miskin menurut daerah",
#'               label = "tab:miskin", sumber = "Badan Pusat Statistik",
#'               garis_total = TRUE)
#' }
#' @export
tabel_skripsi <- function(df, judul, label, sumber = NULL, ket = NULL,
                          align = NULL, nomor_kolom = TRUE,
                          garis_total = FALSE, escape = TRUE) {
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  ncol <- ncol(df)
  if (is.null(align)) align <- .align_default(df)
  if (length(align) != ncol) {
    stop("Panjang 'align' (", length(align), ") tidak sama dengan jumlah kolom (",
         ncol, ").", call. = FALSE)
  }
  hdr <- names(df)
  cells <- vapply(df, function(col) as.character(col), character(nrow(df)))
  cells <- matrix(cells, nrow = nrow(df))
  if (escape) {
    hdr   <- .lx_escape(hdr)
    cells <- apply(cells, 2, .lx_escape)
    cells <- matrix(cells, nrow = nrow(df))
  }

  if (!knitr::is_latex_output()) {
    tampil <- as.data.frame(cells, stringsAsFactors = FALSE)
    names(tampil) <- names(df)
    if (nomor_kolom) {
      nr <- as.data.frame(as.list(paste0("(", seq_len(ncol), ")")),
                          check.names = FALSE, stringsAsFactors = FALSE)
      names(nr) <- names(df)
      tampil <- rbind(nr, tampil)
    }
    return(knitr::kable(tampil, format = "pipe", row.names = FALSE))
  }

  colspec <- paste0("|", paste(align, collapse = "|"), "|")
  rows    <- apply(cells, 1, function(r) paste(r, collapse = " & "))
  n       <- length(rows)

  out <- c(
    "\\par\\addvspace{0.5\\normalbaselineskip}",
    paste0("\\begingroup\\setlength{\\topsep}{0pt}\\setlength{\\partopsep}{0pt}",
           "\\singlespacing\\setlength{\\abovecaptionskip}{0pt}",
           "\\setlength{\\belowcaptionskip}{0pt}"),
    "\\begin{center}",
    "\\sbox\\skripsiblokbox{\\renewcommand{\\arraystretch}{1.15}%",
    sprintf("\\begin{tabular}{%s}", colspec),
    "\\hline",
    paste(paste(hdr, collapse = " & "), "\\\\ \\hline")
  )
  if (nomor_kolom) {
    num  <- paste0("(", seq_len(ncol), ")")
    numc <- paste0("\\multicolumn{1}{", c("|c|", rep("c|", ncol - 1L)), "}{",
                   num, "}")
    out <- c(out, paste(paste(numc, collapse = " & "), "\\\\ \\hline"))
  }
  if (garis_total && n >= 1L) {
    if (n > 1L) out <- c(out, paste0(rows[-n], " \\\\"))
    out <- c(out, "\\hline", paste0(rows[n], " \\\\"))
  } else {
    out <- c(out, paste0(rows, " \\\\"))
  }
  out <- c(out, "\\hline", "\\end{tabular}}%")

  # Judul tabel DI ATAS, rata tepi kiri tabel (lebar = lebar tabel), hang.
  out <- c(out,
    sprintf(paste0("\\parbox[t]{\\wd\\skripsiblokbox}{\\raggedright",
                   "\\captionof{table}{%s}\\label{%s}}\\par"), judul, label),
    "\\nopagebreak\\addvspace{0.35\\normalbaselineskip}",
    "\\usebox\\skripsiblokbox\\par")

  # Sumber/Keterangan rata tepi kiri tabel (lebar = lebar tabel).
  bawah <- character(0)
  if (!is.null(sumber)) {
    bawah <- c(bawah, sprintf("{\\small Sumber: %s}",
                              if (escape) .lx_escape(sumber) else sumber))
  }
  if (!is.null(ket)) {
    bawah <- c(bawah, sprintf("{\\small Keterangan: %s}",
                              if (escape) .lx_escape(ket) else ket))
  }
  if (length(bawah)) {
    out <- c(out, "\\addvspace{0.25\\normalbaselineskip}",
             sprintf(paste0("\\parbox[t]{\\wd\\skripsiblokbox}{\\raggedright",
                            "\\setlength{\\parindent}{0pt}%s}"),
                     paste(bawah, collapse = "\\par ")))
  }
  out <- c(out, "\\end{center}\\endgroup", "\\par\\addvspace{0.5\\normalbaselineskip}")
  knitr::raw_latex(paste(out, collapse = "\n"))
}

#' Tabel panjang lintas-halaman sesuai pedoman
#'
#' Seperti [tabel_skripsi()] tetapi memakai `longtable` untuk tabel yang
#' melampaui satu halaman: judul kolom dan baris nomor kolom **terulang** di
#' tiap halaman, disertai keterangan **"Tabel N (lanjutan)"**. Bentuk tetap grid
#' (garis kolom) dengan huruf `\\small` (>= 8 pt sesuai pedoman).
#'
#' @inheritParams tabel_skripsi
#' @return Objek `knitr::raw_latex` (PDF) atau `knitr::kable` (non-LaTeX).
#' @export
tabel_skripsi_panjang <- function(df, judul, label, sumber = NULL, ket = NULL,
                                  align = NULL, nomor_kolom = TRUE,
                                  escape = TRUE) {
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  ncol <- ncol(df)
  if (is.null(align)) align <- .align_default(df)
  hdr <- names(df)
  cells <- vapply(df, function(col) as.character(col), character(nrow(df)))
  cells <- matrix(cells, nrow = nrow(df))
  if (escape) {
    hdr   <- .lx_escape(hdr)
    cells <- matrix(apply(cells, 2, .lx_escape), nrow = nrow(df))
  }

  if (!knitr::is_latex_output()) {
    tampil <- as.data.frame(cells, stringsAsFactors = FALSE)
    names(tampil) <- names(df)
    if (nomor_kolom) {
      nr <- as.data.frame(as.list(paste0("(", seq_len(ncol), ")")),
                          check.names = FALSE, stringsAsFactors = FALSE)
      names(nr) <- names(df)
      tampil <- rbind(nr, tampil)
    }
    return(knitr::kable(tampil, format = "pipe", row.names = FALSE))
  }

  colspec  <- paste0("|", paste(align, collapse = "|"), "|")
  hdr_row  <- paste(paste(hdr, collapse = " & "), "\\\\ \\hline")
  num      <- paste0("(", seq_len(ncol), ")")
  numc     <- paste0("\\multicolumn{1}{", c("|c|", rep("c|", ncol - 1L)), "}{",
                     num, "}")
  num_row  <- if (nomor_kolom) paste(paste(numc, collapse = " & "), "\\\\ \\hline") else NULL
  baris    <- apply(cells, 1, function(r) paste(paste(r, collapse = " & "), "\\\\"))

  out <- c(
    "\\par\\addvspace{0.5\\normalbaselineskip}",
    sprintf("\\captionof{table}{%s}\\label{%s}", judul, label),
    "\\nopagebreak",
    "{\\singlespacing\\small\\setlength{\\LTpre}{0pt}\\setlength{\\LTpost}{0pt}",
    sprintf("\\begin{longtable}{%s}", colspec),
    "\\hline", hdr_row, num_row,
    "\\endfirsthead",
    sprintf("\\multicolumn{%d}{l}{\\small Tabel \\thetable\\ (lanjutan)}\\\\", ncol),
    "\\hline", hdr_row, num_row,
    "\\endhead",
    "\\hline \\endfoot",
    "\\hline \\endlastfoot",
    baris,
    "\\end{longtable}}"
  )
  if (!is.null(sumber)) {
    out <- c(out, sprintf("{\\small Sumber: %s}",
                          if (escape) .lx_escape(sumber) else sumber))
  }
  if (!is.null(ket)) {
    out <- c(out, sprintf("\\par{\\small Keterangan: %s}",
                          if (escape) .lx_escape(ket) else ket))
  }
  out <- c(out, "\\par\\addvspace{0.5\\normalbaselineskip}")
  knitr::raw_latex(paste(out[!vapply(out, is.null, logical(1))], collapse = "\n"))
}
