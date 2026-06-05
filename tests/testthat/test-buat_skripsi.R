test_that("buat_skripsi membuat struktur proyek dan mengganti token", {
  tmp <- file.path(tempdir(), "uji-skripsi")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

  p <- buat_skripsi(
    path      = tmp,
    judul     = "JUDUL UJI COBA",
    nama      = "Budi Santoso",
    nim       = "221234567",
    peminatan = "Sains Data",
    overwrite = TRUE
  )

  expect_true(dir.exists(p))
  expect_true(file.exists(file.path(p, "_quarto.yml")))
  expect_true(file.exists(file.path(p, "index.qmd")))
  expect_true(file.exists(file.path(p, "apa-stis-id.csl")))
  expect_true(file.exists(file.path(p, "referensi.bib")))
  expect_true(file.exists(file.path(p, "bab", "bab1_pendahuluan.qmd")))
  expect_true(file.exists(file.path(p, "tex", "00_frontmatter.tex")))

  # Token harus tergantikan
  yml <- readLines(file.path(p, "_quarto.yml"), warn = FALSE, encoding = "UTF-8")
  expect_true(any(grepl("JUDUL UJI COBA", yml, fixed = TRUE)))
  expect_false(any(grepl("{{JUDUL}}", yml, fixed = TRUE)))

  fm <- readLines(file.path(p, "tex", "00_frontmatter.tex"), warn = FALSE, encoding = "UTF-8")
  expect_true(any(grepl("Budi Santoso", fm, fixed = TRUE)))
  expect_true(any(grepl("221234567", fm, fixed = TRUE)))
  expect_true(any(grepl("SAINS DATA", fm, fixed = TRUE)))
})

test_that("buat_skripsi menolak menimpa tanpa overwrite", {
  tmp <- file.path(tempdir(), "uji-skripsi-2")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
  buat_skripsi(path = tmp, overwrite = TRUE)
  expect_error(buat_skripsi(path = tmp), "sudah ada")
})

test_that("subjudul menghasilkan blok LaTeX", {
  tmp <- file.path(tempdir(), "uji-skripsi-3")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
  buat_skripsi(path = tmp, subjudul = "Studi Kasus Jawa Timur", overwrite = TRUE)
  fm <- readLines(file.path(tmp, "tex", "00_frontmatter.tex"), warn = FALSE, encoding = "UTF-8")
  expect_true(any(grepl("Studi Kasus Jawa Timur", fm, fixed = TRUE)))
})

test_that("peminatan Sains Data memakai kerangka Bab I-V", {
  tmp <- file.path(tempdir(), "uji-skripsi-sd")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
  buat_skripsi(path = tmp, peminatan = "Sains Data", overwrite = TRUE)
  bab <- list.files(file.path(tmp, "bab"))
  expect_true("bab4_hasil.qmd" %in% bab)
  expect_false("bab4_analisis.qmd" %in% bab)
  idx <- readLines(file.path(tmp, "index.qmd"), warn = FALSE, encoding = "UTF-8")
  expect_true(any(grepl("bab4_hasil.qmd", idx, fixed = TRUE)))
  expect_false(any(grepl("{{INCLUDE_BAB}}", idx, fixed = TRUE)))
})

test_that("peminatan Sistem Informasi memakai kerangka Bab I-VI", {
  tmp <- file.path(tempdir(), "uji-skripsi-si")
  on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
  buat_skripsi(path = tmp, peminatan = "Sistem Informasi Statistik", overwrite = TRUE)
  bab <- list.files(file.path(tmp, "bab"))
  expect_true(all(c("bab3_metode_si.qmd", "bab4_analisis.qmd",
                    "bab5_implementasi.qmd") %in% bab))
  expect_false("bab4_hasil.qmd" %in% bab)
  idx <- readLines(file.path(tmp, "index.qmd"), warn = FALSE, encoding = "UTF-8")
  expect_true(any(grepl("bab5_implementasi.qmd", idx, fixed = TRUE)))
  expect_true(any(grepl("bab5_kesimpulan.qmd", idx, fixed = TRUE)))
})

test_that("path_csl mengembalikan berkas yang ada", {
  expect_true(file.exists(path_csl()))
})
