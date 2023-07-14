#' Known BrAPI Connections
#' 
#' A list of pre-configured BrAPIConnections to known BrAPI servers
#' 
#' @include utils.R
KNOWN_BRAPI_CONNECTIONS = list(
  "T3/Wheat" = createBrAPIConnection("wheat.triticeaetoolbox.org"),
  "T3/Wheat Sandbox" = createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org"),
  "T3/Oat" = createBrAPIConnection("oat.triticeaetoolbox.org"),
  "T3/Oat Sandbox" = createBrAPIConnection("oat-sandbox.triticeaetoolbox.org"),
  "T3/Barley" = createBrAPIConnection("barley.triticeaetoolbox.org"),
  "T3/Barley Sandbox" = createBrAPIConnection("barley-sandbox.triticeaetoolbox.org"),
  "Cassavabase" = createBrAPIConnection("cassavabase.org")
)