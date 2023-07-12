#' BrAPI Connection Class
#'
#' A Reference Class representing a BrAPI connection
#'
#' All fields are required. The properties defined in the connection will be used
#' to construct the final URL to a BrAPI endpoint: $protocol://$host/$path/$version/{...call}
#'
#' @name BrAPIConnection
#'
#' @field protocol The HTTP protocol - either "http" or "https"
#' @field host The hostname of the server to connect to
#' @field path The base path to the BrAPI endpoints (not including the version)
#' @field version The version of BrAPI to use
#'
#' @method get A function for making a BrAPI GET request
#'
#' @export
BrAPIConnection <- setRefClass("BrAPIConnection",

	fields = list(
		protocol = "character",
		host = "character",
		path = "character",
		version = "character"
	),

	methods = list(
		initialize = function(...) {
			callSuper(...)
			if ( length(.self$protocol) == 0 ) {
				.self$protocol = "https"
			}
			if ( length(.self$host) == 0 ) {
				stop("Connection host is required!")
			}
			if ( length(.self$path) == 0 ) {
				.self$path = "/brapi/"
			}
			if ( length(.self$version) == 0 ) {
				.self$version = "v2"
			}
		},
		url = function() {
			protocol <<- .self$protocol
			host <<- .self$host
			path <<- .self$path
			version <<- .self$version
			
			protocol <<- sub(":?/+$", "", protocol)
			host <<- sub("^https?://", "", host)
			path <<- sub("^/+", "", path)
			path <<- sub("/+$", "", path)
			path <<- sub("//+", "/", path)
			
			return(paste0(protocol, '://', host, '/', path, '/', version))
		},
		get = function(call, ...) {
			BrAPIRequest(.self, "GET", call, ...)
		},
		post = function(call, ...) {
			BrAPIRequest(.self, "POST", call, ...)
		},
		put = function(call, ...) {
			BrAPIRequest(.self, "PUT", call, ...)
		}
	)

)
