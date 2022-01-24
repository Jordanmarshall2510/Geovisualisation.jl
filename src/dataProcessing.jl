using DataFrames
using CSV
using HTTP

import Humanize: digitsep

# Reads time series COVID-19 global confirmed cases raw CSV file from repository.
function readGlobalConfirmedCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
    data = CSV.read(url.body, DataFrame)
    return data
end

# Reads time series COVID-19 global deaths raw CSV file from repository.
function readGlobalDeathsCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")
    data = CSV.read(url.body, DataFrame)
    return data
end

# Reads time series COVID-19 global recovered cases raw CSV file from repository.
function readGlobalRecoveredCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv")
    data = CSV.read(url.body, DataFrame)
    return data
end

# Gets total confirmed cases worldwide by summing all countries in dataframe.
function getTotalConfirmedCases(df)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets total recovered cases worldwide by summing all countries in dataframe.
function getTotalRecoveredCases(df)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets total deaths worldwide by summing all countries in dataframe.
function getTotalDeaths(df)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets list of all countries listed in dataframe. If country has multiple entries, the province/state is added also.
function getListOfCountries(df)
    listOfCountries = []
    for x in eachrow(df)
        region = ""
        if !ismissing(x."Province/State")
            region = x."Country/Region" * " (" * x."Province/State" * ")"
        else
            region = x."Country/Region"
        end
        optionObject = (label=region, value=region)
        push!(listOfCountries, optionObject)
    end
    return listOfCountries
end

# Provides start date for date picker.
function getStartDate(df)
    print(names(df)[5])
end

# Provides end date for date picker.
function getEndDate(df)

end

data = readGlobalConfirmedCSV()
getStartDate(data)
