#' Prepare the dataset for the mining stuff
#'
#' This function prepares the dataset removing unuseful character attributes,
#' removing videogames (and videogames-only attributes).\cr\
#' These are the performed operations:
#' \itemize{
#' \item It removes the \code{details.name} attribute, as it's a redundand ambiguous identifier,
#' and the \code{stats.median} column, as it seems to be broken in BGG XMLAPI2.
#' \item Some exploratory analysis bring up that lot of games have yearpublished=0: this is probably a missing
#' set to zero by mistake, so we put to NA (we are aware that we have some very ancient games in the dataset, but we
#' consider them as outliers).
#' \item Finally, we removed games with \code{yearpublished < 1959} (.05 percentile and really unuseful).\cr
#' We are aware that there are some games with \code{yearpublished > 2015}, but we decided to keep those
#' yet unreleased games as they could be useful as test set.
#'}
#' @param bgg.dataset the BoardGames dataset object to prepare
#'
#' @importFrom splitstackshape cSplit_e
#' @importFrom dplyr select "%>%"
#'
#' @export
bgg.prepare.data <- function(bgg.dataset = BoardGames){

  # I really don't want videogames in my DB
  videogames.id <- unique(c(
    which(!is.na(bgg.dataset$stats.rank.family.amiga.pos)),
    which(!is.na(bgg.dataset$stats.rank.family.arcade.pos)),
    which(!is.na(bgg.dataset$stats.rank.family.atarist.pos)),
    which(!is.na(bgg.dataset$stats.rank.family.commodore64.pos))
  )
  )

  bgg.dataset <- bgg.dataset[-videogames.id,]

  bgg.dataset <- select(bgg.dataset, -one_of("details.image", "details.thumbnail", "details.description", "stats.median"))
  bgg.dataset <- select(bgg.dataset, -contains("stats.rank.family.amiga"),
               -contains("stats.rank.family.arcade"),
               -contains("stats.rank.family.atarist"),
               -contains("stats.rank.family.commodore64"),
               -contains("stats.rank.subtype.videogame")
  )

  # Zero value in yearpublished column is a missing, so I convert to NA
  bgg.dataset[which(as.numeric(bgg.dataset$details.yearpublished)==0),]$details.yearpublished <- NA

  # Same for minage, where we're going to put to NA if it's > than 25, too
  bgg.dataset[which(bgg.dataset$details.minage==0 | bgg.dataset$details.minage > 25),]$details.minage <- NA

  # I'm going to filter out games that were released before 1959 or not yet released
  # We're going to loose only 5% of the dataset
  summary(as.numeric(bgg.dataset$details.yearpublished))
  quantile(as.numeric(bgg.dataset$details.yearpublished), seq(0, 1, 0.05), na.rm = TRUE)

  bgg.dataset <- bgg.dataset %>% filter(
    (as.numeric(details.yearpublished) >= 1959) |
      is.na(details.yearpublished)
  )

  return(bgg.dataset)

}

