#' Known BrAPI Connections
#' A list of pre-configured BrAPIConnections to known BrAPI servers
#'
#' These are used in the getBrapiConnection() function when a user requests a connection by name
#' @include utils.R
#' @keywords internal
KNOWN_BRAPI_CONNECTIONS = list(
  "T3/Wheat" = createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/Wheat Sandbox" = createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/WheatCAP" = createBrAPIConnection("wheatcap.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/Oat" = createBrAPIConnection("oat.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/Oat Sandbox" = createBrAPIConnection("oat-sandbox.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/Barley" = createBrAPIConnection("barley.triticeaetoolbox.org", is_breedbase=TRUE),
  "T3/Barley Sandbox" = createBrAPIConnection("barley-sandbox.triticeaetoolbox.org", is_breedbase=TRUE),
  "Cassavabase" = createBrAPIConnection("cassavabase.org", is_breedbase=TRUE),
  "USDA-GRIN Wheat" = createBrAPIConnection("npgsweb.ars-grin.gov", path="/gringlobal/brapi/", params=list(commoncropname = "WHEAT")),
  "USDA-GRIN Oat" = createBrAPIConnection("npgsweb.ars-grin.gov", path="/gringlobal/brapi/", params=list(commoncropname = "OAT")),
  "USDA-GRIN Barley" = createBrAPIConnection("npgsweb.ars-grin.gov", path="/gringlobal/brapi/", params=list(commoncropname = "BARLEY"))
)