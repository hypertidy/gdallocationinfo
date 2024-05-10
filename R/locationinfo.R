
#' Look up points on raster source
#'
#' Input a raster, specify band number if you want anything but the first band. xy is expected to
#' be a matrix: `cbind(lon, lat)`.
#'
#'
#' @param x raster data source
#' @param xy points on the raster (we assume longlat)
#'
#' @return numeric vector
#' @export
#' @importFrom methods new
#' @importFrom gdalraster GDALRaster
#' @importFrom vaster cell_from_xy rowcol_from_cell
#' @importFrom furrr future_map_dbl
#' @examples
#' geb <- "/vsicurl/https://gebco2023.s3.valeria.science/gebco_2023_land_cog.tif"
#' pt <- cbind(c(175.28, -4.72), c(-37.78, 52.22))
#' locationinfo(geb, pt)
locationinfo <- function(x, xy, band = 1L) {
  UseMethod("locationinfo")
}

#' @export
locationinfo.character <- function(x, xy, band = 1L) {
  out <- numeric(nrow(xy))

  ## process cl_arg (-b for band)
  ds <- new(gdalraster::GDALRaster, x)
  if(nzchar(ds$getProjectionRef())) {
    xy <- gdalraster::transform_xy(xy, srs_to = ds$getProjectionRef(), srs_from = gdalraster::srs_to_wkt("EPSG:4326"))
  }
  dm <- c(ds$getRasterXSize(), ds$getRasterYSize())
  ex <- ds$bbox()[c(1, 3, 2, 4)]
  ## fixme if not geoloc in cl_arg this extent should be 0,ncol,0,nrow
  cell <- vaster::cell_from_xy(dm, ex, xy)
  #browser()
  rc <- vaster::rowcol_from_cell(dm, ex, cell) - 1L ## note 0-based here

  bad <- is.na(cell)
  ord <- order(cell[!bad])
  out <- numeric(nrow(xy))
  if (all(bad)) stop("all points fall outside raster")
  #return(cell)
  ## now order and
  ## fixme: uniqueify cell
  ## fixme: batch by blocks
  listtoapply <- split(t(rc), rep(seq_len(nrow(rc)), each = 2L))[!bad][ord]
  fun <- function(.x) ds$read(band, .x[2L], .x[1L], 1L, 1L, 1L, 1L)
  ## pain
  # if (cores[1L] > 1L) {
  #   cl <- parallel::makeCluster(cores[1L], type = "FORK")
  #   browser()
  #   parallel::clusterExport(cl, c("ds"))
  #   out <- parallel::parLapply(cl, listtoapply, fun, ds = ds)
  #   parallel::stopCluster(cl)
  # } else {
  #   out <- lapply(listtoapply, fun)
  # }
  out[!bad] <- furrr::future_map_dbl(listtoapply, fun)[order(ord)]
  ds$close()
  out
  #unlist(out, use.names = FALSE)[order(ord)]
}

