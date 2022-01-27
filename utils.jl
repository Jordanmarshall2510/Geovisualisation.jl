using DataFrames
using CSV
using HTTP
using Dates

import Humanize: digitsep

#################
# Reading of Date
#################

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

# Reads time series COVID-19 global recovered cases raw CSV file from repository.
function readGlobalVaccinationCSV()
    url = HTTP.get("https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/global_data/time_series_covid19_vaccine_doses_admin_global.csv")
    data = CSV.read(url.body, DataFrame)
    data = select!(data, Not(:1:6))
    data = select!(data, Not(:5:6))
    return data
end

###################
# Information Cards
###################

# Gets total confirmed cases worldwide by summing all countries in dataframe.
function getTotalConfirmedCases(df)
    replace!(df[!,ncol(df)], missing => 0)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets total recovered cases worldwide by summing all countries in dataframe.
function getTotalRecoveredCases(df)
    replace!(df[!,ncol(df)], missing => 0)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets total deaths worldwide by summing all countries in dataframe.
function getTotalDeaths(df)
    replace!(df[!,ncol(df)], missing => 0)
    total = sum(df[!,ncol(df)])
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

# Gets total vaccinations worldwide by summing all countries in dataframe.
function getTotalVaccinations(df)
    total = 0
    replace!(df[!,ncol(df)], missing => 0)
    for x in eachrow(df)
        if ismissing(x.Province_State)
            total += x[length(x)]
        end
    end
    if(total == 0)
        return "No Data Available"
    end
    return digitsep(total)
end

###################
# Scatter Map Plot
###################

###################
# Search and filter
###################

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
    date = names(df)[5]
    return formatToDateObject(date)
end

# Provides end date for date picker.
function getEndDate(df)
    date = names(df)[ncol(df)]
    return formatToDateObject(date)
end

###################
# Utility functions
###################

# Converts date provided in the dataframe to a date object.
function formatToDateObject(date)
    date = split(date,"/")
    return Date(parse(Int64, "20" * date[3]), parse(Int64, date[1]), parse(Int64, date[2]))
end