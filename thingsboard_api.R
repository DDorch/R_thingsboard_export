#######################################################


## Loading R functions
for(nm in list.files(path = "./R_functions/", pattern = "[.]R$", full.names = TRUE)){source(nm)}

# Loading libraries
library.load("httr")
library.load("xml2")
library.load("logging")
# Configure Logging
basicConfig('DEBUG')

#' Thingboard API Class
#'
#' @field url URL of the thingsboard IoT platform.
#' @field publicId .
#' @field token .
#'
#' @return
#' @export
#'
#' @examples
#' thinksboard_api = ThingsboardApi(url="http://scada.g-eau.net", publicId=)
ThingsboardApi <- setRefClass("ThingsboardApi",
  fields = list(
    url = "character",
    publicId = "character",
    token = "character"
  ),
  methods = list(
    #' Get authorisation token from thingsboard server for a specific device
    #'
    #' @param url URL of thingsboard server
    #' @param publicId Public ID of the device
    #'
    #' @return list with keys 'token' and 'refreshtoken'
    #'
    #' @examples
    #' getToken(url, publicId) is equivalent to:
    #' curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"publicId":[publicId]}' '[url]'
    getToken = function () {
      res <- POST(
        url = file.cleanpath(url, "api/auth/login/public"),
        body = list(publicId = publicId),
        encode = "json"
      )
      dToken = content(res, as = "parsed", encoding="Latin1")
      token <<- dToken$token
      return (dToken)
    },
    #' Fetch data keys for an entity
    #' See: https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-keys
    #'
    #' @param entityId
    #' @param entityType
    #'
    #' @return
    #' @export
    #'
    #' @examples
    #' Equivalent to:
    #' curl -v -X GET http://localhost:8080/api/plugins/telemetry/DEVICE/ac8e6020-ae99-11e6-b9bd-2b15845ada4e/keys/timeseries \
    #' --header "Content-Type:application/json" \
    #' --header "X-Authorization: $JWT_TOKEN"
    #'
    getKeys = function(entityId, entityType = "DEVICE") {
      res = GET(
        url = file.cleanpath(url, paste("api/plugins/telemetry", entityType, entityId, "keys/timeseries", sep="/")),
        content_type_json(), add_headers(`X-Authorization`= paste("Bearer", token))
      )
      return (content(res, as = "parsed", encoding="Latin1"))
    },
    #' Fetch values from an entity
    #' See: https://thingsboard.io/docs/user-guide/telemetry/#get-telemetry-values
    #'
    #' @param entityId
    #' @param keys Vector with the list of keys from which getting the telemetry values
    #' @param entityType
    #'
    #' @return
    #' @export
    #'
    #' @examples
    #' Equivalent to:
    #' curl -v -X GET http://localhost:8080/api/plugins/telemetry/DEVICE/ac8e6020-ae99-11e6-b9bd-2b15845ada4e/keys/timeseries \
    #' --header "Content-Type:application/json" \
    #' --header "X-Authorization: $JWT_TOKEN"
    #'
    getValues = function(entityId, keys, startTs, endTs, interval, agg = "NONE", entityType = "DEVICE") {
        query = paste(
            paste0("keys=",paste(lapply(keys, url_escape), collapse = ",")),
            paste0("startTs=",startTs),
            paste0("endTs=",endTs),
            paste0("interval=",interval),
            paste0("agg=",agg),
            sep="&"
        )
        #cat("query=",query) # Debug
        res = GET(
            url = file.cleanpath(url, paste("api/plugins/telemetry", entityType, entityId, "values/timeseries", sep="/")),
            query = query,
            content_type_json(),
            add_headers(`X-Authorization`= paste("Bearer", token))
        )
        return (content(res, as = "parsed", encoding="Latin1"))
    }
  )
)




# Requête pour récupérer le JWT token:
# curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"publicId":"a921d8b0-c18c-11e8-ae2f-072f85677f46"}' 'http://scada.dorch.fr/api/auth/login/public'


# Requête pour récupérer une timeseries d'une station valeur moyenne intervalle de temps 15 min
# curl "http://scada.dorch.fr/api/plugins/telemetry/DEVICE/33b45590-c0ff-11e8-8f20-03447990b333/values/timeseries?keys=Chau%20Doc&startTs=1518044207000&endTs=1538044207748&interval=900000&agg=AVG" --header "Content-Type:application/json" --header "X-Authorization: Bearer %JWT_TOKEN%"

# Adresse de l'API : https://thingsboard.io/docs/user-guide/telemetry/
