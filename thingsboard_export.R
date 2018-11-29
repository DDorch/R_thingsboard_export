# Parameters
url = "http://scada.g-e"
# Mekong
publicId = "857c5b20-f3e5-11e8-9dbf-cbc1e37c11e3"
entityId = "f0c9cc10-f3e4-11e8-9dbf-cbc1e37c11e3"
interval = 15*60 # 15 minutes Time step (seconds)
startDate = as.POSIXct("2018-09-27 00:00:00")

# Halle hydraulique
# publicId = "299cedc0-f3e9-11e8-9dbf-cbc1e37c11e3"
# entityId = "18d56d50-f3e9-11e8-9dbf-cbc1e37c11e3"
# interval = 60
# startDate = as.POSIXct("2018-11-01 00:00:00")

endDate = Sys.time()
# Nb Time step by query
nbTs = 100

# options(error=recover)

# Load API
source("thingsboard_api.R")

# Connection
tb_api = ThingsboardApi(url = url, publicId = publicId)
tb_api$getToken()

# Get list of keys
keys = tb_api$getKeys(entityId = entityId)
keys = unlist(keys, use.names=FALSE)
logdebug(paste("keys =",paste(keys,collapse = ", ")))


# Loop over the period
days <- seq(from=startDate, to=endDate,by='days' ) # https://stat.ethz.ch/R-manual/R-devel/library/base/html/seq.Date.html
# Do a loop over keys
# Write dataframe for each key
# Loop over time by 100 time steps
startTs = floor(as.numeric(startDate))
endTs = floor(as.numeric(endDate))
sInterval = Epoch2StringMilli(interval)

EpochMilli2Date<-function(x) {return(as.POSIXct(as.numeric(as.character(x))/1000, tz = "GMT", origin = "1970-01-01"))}

for(key in keys) {
    cat("Proceeding key:",key,"\n")
    # Generate dataframe
    df <- data.frame(matrix(ncol = 2, nrow = 0))

    lastTsi = startTs

    for(Tsi in seq(from = startTs + nbTs * interval, to = endTs, by = nbTs * interval)) {
        # Date conversions to Unix Epoch in milliseconds
        startTsi = Epoch2StringMilli(lastTsi)
        endTsi = Epoch2StringMilli(Tsi)
        # Querying values
        values = tb_api$getValues(entityId, key, startTsi, endTsi, sInterval)
        logdebug("key = %s (%i/%i) - Tsi = %i - Lenght = %i", key, which(keys == key), length(keys), Tsi, length(unlist(values))/2)
        # Merge dataframe rows
        if(length(unlist(values)) > 0) {
            df = rbind(df, matrix(unlist(values), ncol=2, byrow=T))
        }
        lastTsi = Tsi
    }
    df = df[order(df[,1]),]
    df[,1] = t(as.data.frame(lapply(X = df[,1], FUN = EpochMilli2Date)))
    colnames(df) <- c("ts", "values")
    if(nrow(df) > 0) {
        write.csv(df, file = paste("data", Unaccent(key), "csv", sep="."), row.names = FALSE)
    }
}

