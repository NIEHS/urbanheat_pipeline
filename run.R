# .libPaths(
#   grep(
#     paste0("biotools|", Sys.getenv("USER")), .libPaths(),
#     value = TRUE,
#     invert = TRUE
#   )
# )
# cat("Active library paths:\n")
# .libPaths()

cat("Active library paths:\n")
.libPaths()
targets::tar_make()
