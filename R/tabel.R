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

# Normalisasi argumen 'lebar': NULL = lebar alami; angka >1 dianggap persen
# (mis. 80 -> 0,8); hasil pecahan 0<lebar<=1 dari \textwidth.
.norm_lebar <- function(lebar) {
  if (is.null(lebar)) return(NULL)
  if (!is.numeric(lebar) || length(lebar) != 1L || is.na(lebar)) {
    stop("'lebar' harus satu angka, mis. 0.8 atau 80 (persen).", call. = FALSE)
  }
  if (lebar > 1) lebar <- lebar / 100
  if (lebar <= 0 || lebar > 1) {
    stop("'lebar' di luar rentang. Gunakan 0 < lebar <= 1 (atau 1-100 persen).",
         call. = FALSE)
  }
  lebar
}

# Spesifikasi kolom grid. Bila 'lebar' NULL -> kolom alami (l/c/r).
# Bila 'lebar' diberi -> kolom 'X' (tabularx/xltabular) yang berbagi lebar sama
# rata dan membungkus teks, dengan perataan sesuai 'align'.
.colspec_grid <- function(align, lebar) {
  if (is.null(lebar)) {
    return(paste0("|", paste(align, collapse = "|"), "|"))
  }
  xmap <- c(l = ">{\\raggedright\\arraybackslash}X",
            c = ">{\\centering\\arraybackslash}X",
            r = ">{\\raggedleft\\arraybackslash}X")
  cols <- unname(xmap[align])
  cols[is.na(cols)] <- xmap[["l"]]
  paste0("|", paste(cols, collapse = "|"), "|")
}

# Spesifikasi kolom untuk tabel PANJANG ber-lebar-target (mengisi lebar tabel).
# Kolom LABEL (align "l") dibuat 'X' (melar, membungkus) agar menyerap sisa ruang
# sehingga tabel mengisi penuh lebar target; kolom ANGKA (align "r"/"c") tetap
# lebar alami agar ringkas. Dijamin minimal satu kolom 'X' (bila tak ada kolom
# "l", kolom pertama dijadikan 'X') supaya tabel benar-benar mencapai lebar
# target -> batas KANAN terkontrol & seragam.
.colspec_grid_fill <- function(align) {
  xmap <- c(l = ">{\\raggedright\\arraybackslash}X",
            c = ">{\\centering\\arraybackslash}X",
            r = ">{\\raggedleft\\arraybackslash}X")
  is_label <- align == "l"
  if (!any(is_label)) is_label[1] <- TRUE  # jamin >=1 kolom melar
  cols <- ifelse(is_label, unname(xmap[align]), align)
  cols[is.na(cols)] <- "l"
  paste0("|", paste(cols, collapse = "|"), "|")
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
#' @param lebar Lebar tabel sebagai pecahan/persen dari lebar teks (margin).
#'   `NULL` (default): lebar mengikuti isi (alami). Angka `0 < lebar <= 1`
#'   dipakai langsung (mis. `0.8` = 80%), sedangkan angka `> 1` dianggap persen
#'   (mis. `80`). Bila diisi, kolom dibuat sama lebar (tipe `X`) dan teks
#'   membungkus agar total tabel persis selebar yang diminta.
#' @param regang_baris Faktor tinggi/kerapatan baris (`\\arraystretch`). Default
#'   `1.15`. Nilai lebih kecil (mis. `1.0`) membuat baris **agak rapat**, nilai
#'   lebih besar (mis. `1.4`) membuat baris **agak longgar**.
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
#' # Lebar 80% margin, baris agak rapat:
#' tabel_skripsi(df, "Contoh tabel 80% lebar", label = "tab:lebar",
#'               lebar = 0.8, regang_baris = 1.0)
#' }
#' @export
tabel_skripsi <- function(df, judul, label, sumber = NULL, ket = NULL,
                          align = NULL, nomor_kolom = TRUE,
                          garis_total = FALSE, lebar = NULL,
                          regang_baris = 1.15, escape = TRUE) {
  lebar <- .norm_lebar(lebar)
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

  colspec <- .colspec_grid(align, lebar)
  rows    <- apply(cells, 1, function(r) paste(r, collapse = " & "))
  n       <- length(rows)
  env_open  <- if (is.null(lebar)) sprintf("\\begin{tabular}{%s}", colspec) else
    sprintf("\\begin{tabularx}{%s\\textwidth}{%s}",
            formatC(lebar, format = "f", digits = 3), colspec)
  env_close <- if (is.null(lebar)) "\\end{tabular}" else "\\end{tabularx}"

  out <- c(
    "\\par\\addvspace{0.5\\normalbaselineskip}",
    paste0("\\begingroup\\setlength{\\topsep}{0pt}\\setlength{\\partopsep}{0pt}",
           "\\singlespacing\\setlength{\\abovecaptionskip}{0pt}",
           "\\setlength{\\belowcaptionskip}{0pt}"),
    "\\begin{center}",
    sprintf("\\sbox\\skripsiblokbox{\\renewcommand{\\arraystretch}{%s}%%",
            formatC(regang_baris, format = "f", digits = 2)),
    env_open,
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
  out <- c(out, "\\hline", env_close, "}%")

  # Judul tabel DI ATAS, DIPUSATKAN (justification=centering; boleh melebihi tepi
  # kiri-kanan tabel). Jarak judul -> tabel ~1 spasi (pedoman), seragam.
  out <- c(out,
    sprintf("\\captionof{table}{%s}\\label{%s}\\par", judul, label),
    "\\nopagebreak\\addvspace{0.85\\normalbaselineskip}",
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
#' Seperti [tabel_skripsi()] tetapi memakai `longtable`/`xltabular` untuk tabel
#' yang melampaui satu halaman: judul kolom dan baris nomor kolom **terulang** di
#' tiap halaman, disertai keterangan **"Tabel N (lanjutan)"**. Bentuk tetap grid
#' (garis kolom) dengan huruf `\\small` (>= 8 pt sesuai pedoman).
#'
#' Berbeda dengan [tabel_skripsi()], **lebar tabel panjang minimal 80% lebar
#' teks** dengan batas kiri (rata margin) dan batas kanan terkontrol pada lebar
#' target, sehingga tepi tabel rapi dan seragam. Kolom label (perataan `"l"`)
#' melebar untuk mengisi ruang, sedangkan kolom angka tetap ringkas.
#'
#' @inheritParams tabel_skripsi
#' @param lebar Lebar tabel sebagai pecahan/persen dari lebar teks. `NULL`
#'   (default) memakai **0,8 (80%)**. Nilai `< 0,8` dinaikkan otomatis ke 0,8
#'   (minimum); nilai `> 1` dianggap persen; maksimum 1 (lebar penuh).
#' @return Objek `knitr::raw_latex` (PDF) atau `knitr::kable` (non-LaTeX).
#' @export
tabel_skripsi_panjang <- function(df, judul, label, sumber = NULL, ket = NULL,
                                  align = NULL, nomor_kolom = TRUE,
                                  lebar = NULL, regang_baris = 1.15,
                                  escape = TRUE) {
  lebar <- .norm_lebar(lebar)
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

  # --- Lebar tabel panjang: MINIMAL 80% lebar teks, dengan batas KIRI & KANAN
  #     terkontrol. Pada longtable lebar alami tak dapat diukur, sehingga tabel
  #     panjang selalu memakai 'xltabular' ber-lebar-target agar tepi kanan pasti
  #     (tidak menggantung mengikuti isi). Lebar efektif = max(lebar, 0.8), maks 1.
  #     Bila pengguna memberi lebar < 0.8, dinaikkan ke 0.8 (minimum pedoman lokal).
  lebar_eff <- if (is.null(lebar)) 0.8 else max(lebar, 0.8)
  if (!is.null(lebar) && lebar < 0.8) {
    message("tabel_skripsi_panjang(): 'lebar' (", lebar,
            ") dinaikkan ke 0,8 (minimum 80% lebar halaman untuk tabel panjang).")
  }
  lebar_eff <- min(lebar_eff, 1)
  lebar_str <- formatC(lebar_eff, format = "f", digits = 3)

  # Kolom: label ('l') dibuat melar ('X') agar tabel mengisi penuh lebar target
  # (kolom angka tetap ringkas) -> batas kanan rapi di lebar target.
  colspec  <- .colspec_grid_fill(align)
  hdr_row  <- paste(paste(hdr, collapse = " & "), "\\\\ \\hline")
  num      <- paste0("(", seq_len(ncol), ")")
  numc     <- paste0("\\multicolumn{1}{", c("|c|", rep("c|", ncol - 1L)), "}{",
                     num, "}")
  num_row  <- if (nomor_kolom) paste(paste(numc, collapse = " & "), "\\\\ \\hline") else NULL
  baris    <- apply(cells, 1, function(r) paste(paste(r, collapse = " & "), "\\\\"))
  env_open  <- sprintf("\\begin{xltabular}{%s\\textwidth}{%s}", lebar_str, colspec)
  env_close <- "\\end{xltabular}"

  # Lebar blok judul/sumber = lebar TABEL (lebar_eff), agar batas KIRI judul
  # (termasuk judul panjang yang membungkus) PERSIS sejajar tepi kiri tabel, dan
  # batas KANAN-nya sejajar tepi kanan tabel - seragam dengan tabel_skripsi().
  blok_w <- sprintf("%s\\textwidth", lebar_str)

  out <- c(
    "\\par\\addvspace{0.5\\normalbaselineskip}",
    # Judul -> tabel ~1 spasi, seragam dengan tabel biasa (pedoman).
    paste0("\\begingroup\\singlespacing\\setlength{\\abovecaptionskip}{0pt}",
           "\\setlength{\\belowcaptionskip}{0pt}"),
    # Judul tabel: DIPUSATKAN di halaman (boleh melebihi tepi kiri-kanan tabel).
    sprintf("\\captionof{table}{%s}\\label{%s}\\par", judul, label),
    "\\nopagebreak\\addvspace{0.85\\normalbaselineskip}\\nopagebreak",
    # Tabel DIPUSATKAN di halaman (pedoman: tabel simetris di tengah). Lebar tabel
    # tetap (lebar_eff) sehingga blok judul/sumber yang juga dipusatkan berimpit
    # tepi kiri & kanannya dengan tabel. \LTleft=\fill, \LTright=\fill.
    sprintf(paste0("{\\small\\renewcommand{\\arraystretch}{%s}",
                   "\\setlength{\\LTpre}{0pt}\\setlength{\\LTpost}{0pt}",
                   "\\setlength{\\LTleft}{\\fill}\\setlength{\\LTright}{\\fill}"),
            formatC(regang_baris, format = "f", digits = 2)),
    env_open,
    "\\hline", hdr_row, num_row,
    "\\endfirsthead",
    sprintf("\\multicolumn{%d}{l}{\\small Tabel \\thetable\\ (lanjutan)}\\\\", ncol),
    "\\hline", hdr_row, num_row,
    "\\endhead",
    "\\hline \\endfoot",
    "\\hline \\endlastfoot",
    baris,
    env_close, "}",
    "\\endgroup")
  # Sumber/Keterangan: blok selebar tabel, DIPUSATKAN; teks rata kiri sehingga
  # batas kirinya berimpit dengan tepi kiri tabel (seragam dengan tabel_skripsi).
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
             sprintf(paste0("\\centerline{\\parbox[t]{%s}{\\raggedright",
                            "\\setlength{\\parindent}{0pt}%s}}"),
                     blok_w, paste(bawah, collapse = "\\par ")))
  }
  out <- c(out, "\\par\\addvspace{0.5\\normalbaselineskip}")
  knitr::raw_latex(paste(out[!vapply(out, is.null, logical(1))], collapse = "\n"))
}
