using DataFrames
using CSV
using HTTP

# Reads time series COVID-19 global confirmed cases raw CSV file from repository.
function readGlobalConfirmedCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
    data = CSV.read(url.body, DataFrame)
    println(data)
end

# Reads time series COVID-19 global deaths raw CSV file from repository.
function readGlobalDeathsCSV()

end

# Reads time series COVID-19 global recovered cases raw CSV file from repository.
function readGlobalRecoveredCSV()

end

function removeUnusedData()

end

function printData()

end

function getTotalConfirmedCases()
    
end

function getTotalRecoveredCases()
    
end

function getTotalDeaths()
    
end

function getTotalConfirmedCases()
    
end
