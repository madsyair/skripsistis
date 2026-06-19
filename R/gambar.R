# Pembantu penyajian GAMBAR sesuai pedoman KS 2025.
#
# Senada dengan tabel_skripsi(): gambar disajikan NON-float (tidak mengambang)
# sehingga muncul tepat pada posisi penulisan. Urutan sesuai pedoman:
# GAMBAR -> SUMBER -> JUDUL "Gambar N." (judul di paling bawah, sumber menempel
# langsung di bawah gambar).

#' Gambar sesuai pedoman (non-float, judul & sumber di bawah)
#'
#' Menyisipkan berkas gambar sebagai gambar yang patuh Pedoman KS 2025: gambar
#' rata tengah dengan urutan **gambar -> Sumber -> judul** (judul "Gambar N. ..."
#' di paling bawah, penomoran otomatis via `\\captionof{figure}`; baris
#' **Sumber**/**Keterangan** menempel langsung di bawah gambar). Bersifat
#' *non-float* sehingga tidak berpindah halaman dan sumber tidak terlepas dari
#' gambar. Berjarak ~3 spasi dari teks.
#'
#' Simpan plot ke berkas terlebih dahulu (mis. `png()`/`ggplot2::ggsave()`),
#' lalu panggil fungsi ini dengan path berkas tersebut.
#'
#' @param path Path berkas gambar (relatif terhadap proyek), mis.
#'   `"img/kerangka.png"`.
#' @param judul Judul gambar (tanpa kata "Gambar N." dan tanpa titik akhir).
#' @param label Label LaTeX untuk rujuk silang, mis. `"fig:bar"` (hindari awalan
#'   `fig-` agar tidak ditangani ulang oleh Quarto). Rujuk dengan `\\ref{label}`.
#' @param sumber Teks sumber (tanpa kata "Sumber:"). `NULL` (default) bila tidak
#'   ada / olahan sendiri.
#' @param ket Keterangan tambahan (menempel di bawah gambar, sebelum judul).
#' @param lebar Lebar gambar sebagai panjang LaTeX. Default `"0.8\\linewidth"`.
#'   Diabaikan bila `tikz = TRUE` (ukuran diatur saat membuat berkas `tikz()`).
#' @param tikz Jika `TRUE`, `path` adalah berkas `.tex` hasil
#'   `tikzDevice::tikz()` dan disisipkan dengan \code{\\input} (bukan
#'   `\\includegraphics`), sehingga **font teks di dalam grafik sama persis**
#'   dengan font naskah. Default `FALSE`.
#' @param escape Lolos-kan karakter khusus pada judul/sumber. Default `TRUE`.
#' @param simpan Bila diisi path berkas (mis. \code{"tex/tabel-miskin.tex"}),
#'   kode LaTeX ditulis ke berkas itu dan disisipkan via \code{\\input}; mahasiswa
#'   dapat mengedit berkas tersebut untuk penyesuaian manual. Default \code{NULL}
#'   (kode dikembalikan inline seperti biasa).
#' @param timpa Bila \code{FALSE} (default) dan berkas \code{simpan} sudah ada,
#'   berkas TIDAK ditimpa sehingga editan dipertahankan; \code{TRUE} membuat ulang.
#' @return Objek `knitr::raw_latex` (PDF) atau `knitr::include_graphics`
#'   (non-LaTeX).
#' @examples
#' \dontrun{
#' png("img/bar.png", width = 1500, height = 960, res = 220)
#' barplot(c(7, 12.9, 9.5), names.arg = c("Kota", "Desa", "Total"))
#' dev.off()
#' gambar_skripsi("img/bar.png", "Persentase penduduk miskin menurut daerah",
#'                label = "fig:bar", sumber = "Badan Pusat Statistik")
#' }
#' @export
gambar_skripsi <- function(path, judul, label, sumber = NULL, ket = NULL,
                           lebar = "0.8\\linewidth", tikz = FALSE,
                           escape = TRUE, simpan = NULL, timpa = FALSE) {
  if (!knitr::is_latex_output()) {
    return(knitr::include_graphics(path))
  }
  jud <- if (escape) .lx_escape(judul) else judul
  # Urutan sesuai pedoman (lih. contoh Gambar 5): GAMBAR -> SUMBER -> JUDUL.
  # Sumber & judul rata tepi kiri gambar (lebar = lebar gambar); blok di tengah.
  isi_box <- if (tikz) {
    sprintf("\\input{%s}", path)            # grafik LaTeX (tikz); font = font naskah
  } else {
    sprintf("\\includegraphics[width=%s]{%s}", lebar, path)
  }
  out <- c(
    "\\par\\addvspace{0.5\\normalbaselineskip}",
    paste0("\\begingroup\\setlength{\\topsep}{0pt}\\setlength{\\partopsep}{0pt}",
           "\\singlespacing\\setlength{\\abovecaptionskip}{0pt}",
           "\\setlength{\\belowcaptionskip}{0pt}"),
    "\\begin{center}",
    sprintf("\\sbox\\skripsiblokbox{%s}%%", isi_box),
    "\\usebox\\skripsiblokbox\\par",
    "\\addvspace{0.4\\normalbaselineskip}"
  )
  # Sumber & Keterangan: rata KIRI pada tepi kiri gambar (lebar = lebar gambar),
  # diletakkan SEBELUM judul (pedoman). Judul gambar sendiri DIPUSATKAN.
  if (!is.null(sumber) || !is.null(ket)) {
    out <- c(out,
      "\\parbox[t]{\\wd\\skripsiblokbox}{\\raggedright\\setlength{\\parindent}{0pt}%")
    if (!is.null(sumber)) {
      out <- c(out, sprintf("{\\small Sumber: %s}\\par",
                            if (escape) .lx_escape(sumber) else sumber))
    }
    if (!is.null(ket)) {
      out <- c(out, sprintf("{\\small Keterangan: %s}\\par",
                            if (escape) .lx_escape(ket) else ket))
    }
    out <- c(out, "}\\par")
  }
  # Judul gambar di TENGAH (justification=centering pada preamble).
  out <- c(out,
           sprintf("\\captionof{figure}{%s}\\label{%s}", jud, label))
  out <- c(out, "\\end{center}\\endgroup", "\\par\\addvspace{0.5\\normalbaselineskip}")
  .keluaran_latex(paste(out, collapse = "\n"), simpan, timpa)
}

#' Konfigurasi tikzDevice agar grafik R memakai font naskah (XeLaTeX)
#'
#' Mengatur opsi global \pkg{tikzDevice} supaya grafik yang dibuat dengan
#' `tikzDevice::tikz()` diukur/dikompilasi memakai XeLaTeX dan **font yang sama
#' dengan naskah** (mis. Times New Roman / TeX Gyre Termes). Dengan demikian
#' label sumbu, angka, dan judul di dalam grafik tampak serasi dengan teks.
#' Panggil sekali di awal dokumen (chunk *setup*), lalu buat grafik dengan
#' `tikz("img/plot.tex", ...)` dan sisipkan via
#' `gambar_skripsi("img/plot.tex", ..., tikz = TRUE)`.
#'
#' @param font Nama font utama (harus tersedia di sistem). Default
#'   `"TeX Gyre Termes"` (metrik identik Times New Roman). Ganti menjadi
#'   `"Times New Roman"` bila font tersebut terpasang.
#' @return Tidak mengembalikan nilai; mengatur opsi global tikzDevice.
#' @examples
#' \dontrun{
#' setup_tikz_skripsi()
#' tikzDevice::tikz("img/plot.tex", width = 4.6, height = 3.0, standAlone = FALSE)
#' plot(1:10, family = "serif")
#' dev.off()
#' gambar_skripsi("img/plot.tex", "Judul", label = "fig:plt", tikz = TRUE)
#' }
#' @export
setup_tikz_skripsi <- function(font = "TeX Gyre Termes") {
  options(tikzDefaultEngine = "xetex")
  options(tikzXelatexPackages = c(
    "\\usepackage{tikz}",
    "\\usepackage{amsmath}",
    "\\usepackage{fontspec}",
    sprintf("\\setmainfont{%s}", font)
  ))
  invisible(TRUE)
}
