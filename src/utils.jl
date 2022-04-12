using DataFrames
using CSV
using HTTP
using Dates
using Memoize
using Statistics

import Humanize: digitsep

export readGlobalConfirmedCSV
export readGlobalDeathsCSV
export readGlobalRecoveredCSV
export readGlobalVaccinationCSV
export getTotalConfirmedCases
export getTotalRecoveredCases
export getTotalDeaths
export getTotalVaccinations
export getTotalCaseFatality
export getCaseFatalityDataframe
export getTopSixFromDataframe
export getListOfCountries
export getStartDate
export getEndDate
export formatToDateObject
export convertTimeSeriesData

#################
# Reading of Date
#################

"""
    readGlobalConfirmedCSV()

Reads time series COVID-19 global confirmed cases raw CSV file from repository.

Returns dataframe of global confirmed cases.
"""
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

"""
    readGlobalDeathsCSV()

Reads time series COVID-19 global deaths raw CSV file from repository.

Returns dataframe of global death cases.
"""
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

"""
    readGlobalRecoveredCSV

Reads time series COVID-19 global recovered cases raw CSV file from repository.

Returns dataframe of global recovered cases.
"""
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


"""
    readGlobalVaccinationCSV    

Reads time series COVID-19 global recovered cases raw CSV file from repository.

Returns dataframe of global vaccination cases.
"""
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
    for i in 4:size(data,2)
        replace!(data[!,i], missing => 0)
    end
    return data
end

###################
# Information Cards
###################

"""
    getTotalConfirmedCases   

Gets total confirmed cases worldwide by summing all countries in dataframe up to specified date. 

Returns number of total confirmed cases of country at a specific date.
"""
@memoize function getTotalConfirmedCases(df, country, date)
    date = Dates.format(date, "m/d/yy")
    if country == "Global"
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        total = df[df."Country/Region" .== country, date]
        if(isempty(total) || total[1] == 0)
            return "No Data Available"
        else
            return digitsep(total[1])
        end
    end
end

"""
    getTotalRecoveredCases   

Gets total recovered cases worldwide by summing all countries in dataframe up to specified date. 

Returns number of total recovered cases of country at a specific date.
"""
@memoize function getTotalRecoveredCases(df, country, date)
    date = Dates.format(date, "m/d/yy")
    if country == "Global"
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        total = df[df."Country/Region" .== country, date]
        if(isempty(total) || total[1] == 0)
            return "No Data Available"
        else
            return digitsep(total[1])
        end
    end
end

"""
    getTotalDeathsCases   

Gets total deaths cases worldwide by summing all countries in dataframe up to specified date. 

Returns number of total deaths cases of country at a specific date.
"""
@memoize function getTotalDeaths(df, country, date)
    date = Dates.format(date, "m/d/yy")
    if country == "Global"
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total == 0)
            return "No Data Available"
        end
        return digitsep(total)
    else
        total = df[df."Country/Region" .== country, date]
        if(isempty(total) || total[1] == 0)
            return "No Data Available"
        else
            return digitsep(total[1])
        end
    end
end


"""
    getTotalVaccinations   

Gets total vaccinations worldwide by summing all countries in dataframe.

Returns number of total vaccinations in a country at a specific date.
"""
@memoize function getTotalVaccinations(df, country, date)
    if(date >= Date(2020,12,12))
        date = Dates.format(date, "yyyy-mm-dd")
        if country == "Global"
            total = sum(df[!,date])
            if(total == 0)
                return "No Data Available"
            end
            return digitsep(total)
        else
            total = df[df."Country/Region" .== country, date]
            if(isempty(total) || total[1] == 0)
                return "No Data Available"
            else
                return digitsep(total[1])
            end
        end
    end
    return "Pre-vaccination date selected"
end

"""
    getTotalCaseFatality   

Gets total case fatality rate worldwide.

Returns case fatality rate in a country at a specific date.
"""
@memoize function getTotalCaseFatality(df, country, date)
    if country == "Global"
        date = Dates.format(date, "m/d/yy")
        replace!(df[!,date], missing => 0)
        total = sum(df[!,date])
        if(total[1] == 0)
            return "No Data Available"
        end
        return round(total; digits=3)
    else
        date = Dates.format(date, "m/d/yy")
        total = df[df."Country/Region" .== country, date]
        if(isempty(total) || total[1] == 0)
            return "No Data Available"
        else
            return round(total[1]; digits=3)
        end
    end
end

"""
    getTopSixFromDataframe   

Gets top six countries for selected attribute worldwide.

Returns country and value for table.
"""
@memoize function getTopSixFromDataframe(df)
    topSixIndexes = sortperm(df[!, end], rev=true)

    contents = []

    for i in 1:6
        value = string(df[topSixIndexes[i], end])
        if occursin(".",value)
            value = round(parse(Float32, value); digits=3)
        else
            value = digitsep(parse(Int32, value))
        end 
        push!(contents,html_tr([html_td(df."Country/Region"[topSixIndexes[i]]), html_td(value)]))
    end

    return contents
end

"""
    getStatisticsTableForCountry   

Gets statistics for table for specified country. Dataframes are already filtered.

Returns statistics with values for table in country view
"""
@memoize function getStatisticsTableForCountry(filteredConfirmedData, filteredDeathsData, filteredVaccinationData)

    confirmed = convertTimeSeriesData(collect(filteredConfirmedData[!, 4:end][1,:]))
    deaths = convertTimeSeriesData(collect(filteredDeathsData[!, 4:end][1,:]))
    vaccinations = convertTimeSeriesData(collect(filteredVaccinationData[!, 4:end][1,:]))

    content = [
        html_tr([html_td("Highest Confirmed Cases (Day)"), html_td(findmax(confirmed)[1])]),
        html_tr([html_td("Highest Deaths Cases (Day)"), html_td(findmax(deaths)[1])]),
        html_tr([html_td("Highest Vaccinations (Day)"), html_td(findmax(vaccinations)[1])]),
        html_tr([html_td("Mean Confirmed Cases"), html_td(round(mean(confirmed), digits=3))]),
        html_tr([html_td("Mean Death Cases"), html_td(round(mean(deaths), digits=3))]),
        html_tr([html_td("Mean Vaccinations"), html_td(round(mean(vaccinations), digits=3))]),
    ]

    return content
end

###################
# Scatter Map Plot
###################

"""
    getCaseFatalityDataframe   

Gets case fatality rate dataframe from confirmed and death dataframes.

Returns case fatality rate dataframe.
"""
function getCaseFatalityDataframe(confirmedData, deathsData)
    countries = confirmedData[:,1:3]
    confirmed = copy(confirmedData)
    deaths = copy(deathsData)
    confirmed = select!(confirmed, Not(:1:3))
    deaths = select!(deaths, Not(:1:3))
    caseFatality = confirmed ./ deaths
    for col in eachcol(caseFatality)
        replace!(col, Inf=>0)
        replace!(col, NaN=>0)
    end
    caseFatalityData = hcat(countries, caseFatality)
    return caseFatalityData
end

###################
# Search and filter
###################

"""
    getListOfCountries   

Gets list of all countries listed in dataframe. If country has multiple entries, the province/state is added also.

Returns array of countries for dropdown.
"""
function getListOfCountries(df)
    options = [(label = "Global", value = "Global")]
    for country in df."Country/Region"
        option = (label = country, value = country)
        push!(options, option)
    end
    return options
end

"""
    getStartDate   

Provides start date for date picker.

Returns date object of start date.
"""
function getStartDate(df)
    date = names(df)[4]
    return formatToDateObject(date)
end

"""
    getEndDate   

Provides end date for date picker.

Returns date object of end date.
"""
function getEndDate(df)
    date = names(df)[end]
    return formatToDateObject(date)
end

###################
# Utility functions
###################

"""
    formatToDateObject   

Converts date format provided in the dataframe to a date object.

Returns date object of date string.
"""
function formatToDateObject(date)
    if occursin("/", date)
        date = split(date,"/")
        return Date(parse(Int64, "20" * date[3]), parse(Int64, date[1]), parse(Int64, date[2]))
    elseif occursin("-", date)
        return Date(date)
    end
end

"""
    convertTimeSeriesData   

Converts array of integer timeseries data into regular values.

Returns array of values.
"""
function convertTimeSeriesData(data)
    finalData = []
    for (index, value) in enumerate(data)
        if(index != 1)
            finalValue = value - data[index-1]
            if(finalValue < 0) 
                finalValue = 0
            end
            push!(finalData, finalValue)
        end
    end
    return finalData
end