library(targets)
tar_load(my_cs)

output_folder <- "./output/"

# List all directories in the output folder
directories <- list.dirs(output_folder, full.names = TRUE, recursive = FALSE)

# Loop through each directory and rename it
for (dir in directories) {
  dir_name <- basename(dir)
  match <- regmatches(dir_name, regexec("^(.*)_(\\d{6})$", dir_name))
  city <- match[[1]][2]
  yyyymm <- match[[1]][3]
  st <- my_cs$ST[
    gsub("[.]", "", gsub("[ ]", "_", tolower(my_cs$NAME))) == city
  ] |>
    unique() |>
    tolower()
  new_dir_name <- paste0(st, "_", city, "_", yyyymm)
  new_dir_path <- file.path(output_folder, new_dir_name)
  file.rename(dir, new_dir_path)
  cat("Renamed:", dir, "to", new_dir_path, "\n")

  files <- list.files(new_dir_path, full.names = TRUE)
  for (file in files) {
    file_name <- basename(file)
    new_file_name <- gsub(city, paste0(st, "_", city), file_name)
    new_file_path <- file.path(new_dir_path, new_file_name)
    file.rename(file, new_file_path)
    cat("Renamed file:", file, "to", new_file_path, "\n")
  }
}
