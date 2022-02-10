using DataFrames
using CSV
using HTTP
using Dates
using Memoize

import Humanize: digitsep

#################
# Reading of Date
#################

# Reads time series COVID-19 global confirmed cases raw CSV file from repository.
@memoize function readGlobalConfirmedCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
    data = CSV.read(url.body, DataFrame)
    for row in eachrow(data)
        if !ismissing(row."Province/State")
            row."Country/Region" *= " (" * row."Province/State" * ")"
        end
    end
    select!(data, Not(:"Province/State"))
    return data
end

# Reads time series COVID-19 global deaths raw CSV file from repository.
@memoize function readGlobalDeathsCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")
    data = CSV.read(url.body, DataFrame)
    for row in eachrow(data)
        if !ismissing(row."Province/State")
            row."Country/Region" *= " (" * row."Province/State" * ")"
        end
    end
    select!(data, Not(:"Province/State"))
    return data
end

# Reads time series COVID-19 global recovered cases raw CSV file from repository.
@memoize function readGlobalRecoveredCSV()
    url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv")
    data = CSV.read(url.body, DataFrame)
    for row in eachrow(data)
        if !ismissing(row."Province/State")
            row."Country/Region" *= " (" * row."Province/State" * ")"
        end
    end
    select!(data, Not(:"Province/State"))
    return data
end

# Reads time series COVID-19 global recovered cases raw CSV file from repository.
@memoize function readGlobalVaccinationCSV()
    url = HTTP.get("https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/global_data/time_series_covid19_vaccine_doses_admin_global.csv")
    data = CSV.read(url.body, DataFrame)
    data = select!(data, Not(:1:6))
    data = select!(data, Not(:5:6))
    rename!(data, [:"Province_State", :"Country_Region", :"Long_"] .=>  [:"Province/State", :"Country/Region", :"Long"])
    for row in eachrow(data)
        if !ismissing(row."Province/State")
            row."Country/Region" *= " (" * row."Province/State" * ")"
        end
    end
    select!(data, Not(:"Province/State"))
    return data
end

###################
# Information Cards
###################

# Gets total confirmed cases worldwide by summing all countries in dataframe up to specified date. 
@memoize function getTotalConfirmedCases(df, country, date)
    if country == "Global"
        date = Dates.format(date, "m/d/yy")
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        date = Dates.format(date, "m/d/yy")
        total = df[df."Country/Region" .== country, date]
        return digitsep(total[1])
    end
end

# Gets total recovered cases worldwide by summing all countries in dataframe up to specified date.
@memoize function getTotalRecoveredCases(df, country, date)
    if country == "Global"
        date = Dates.format(date, "m/d/yy")
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        date = Dates.format(date, "m/d/yy")
        total = df[df."Country/Region" .== country, date]
        return digitsep(total[1])
    end
end

# Gets total deaths worldwide by summing all countries in dataframe up to specified date.
@memoize function getTotalDeaths(df, country, date)
    if country == "Global"
        date = Dates.format(date, "m/d/yy")
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        date = Dates.format(date, "m/d/yy")
        total = df[df."Country/Region" .== country, date]
        return digitsep(total[1])
    end
end

# Gets total vaccinations worldwide by summing all countries in dataframe.
@memoize function getTotalVaccinations(df, country, date)
    if country == "Global"
        date = Dates.format(date, "yyyy-mm-dd")
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        date = Dates.format(date, "yyyy-mm-dd")
        total = df[df."Country/Region" .== country, date]
        return digitsep(total[1])
    end
end

###################
# Scatter Map Plot
###################

###################
# Search and filter
###################

# Gets list of all countries listed in dataframe. If country has multiple entries, the province/state is added also.
function getListOfCountries(df)
    options = [(label = "Global", value = "Global")]
    for country in df."Country/Region"
        option = (label = country, value = country)
        push!(options, option)
    end
    return options
end

# Provides start date for date picker.
function getStartDate(df)
    date = names(df)[4]
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

# Converts date format provided in the dataframe to a date object.
function formatToDateObject(date)
    if occursin("/", date)
        date = split(date,"/")
        return Date(parse(Int64, "20" * date[3]), parse(Int64, date[1]), parse(Int64, date[2]))
    elseif occursin("-", date)
        return Date(date)
    end
end

# Converts date object string to date format provided in the dataframe.
function DateObjectToFormat(date)
    date = join(collect(date)[3:length(date)])
    date = split(date,"-")
    return string(parse(Int64, date[2])) * "/" * string(parse(Int64, date[3])) * "/" * string(parse(Int64, date[1]))
end