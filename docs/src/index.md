# COVID-19 Geovisualisation Documentation

## Introduction
This web application is an interactive geographical visualiser based on COVID-19 data provided by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University.

The global view GUI consists of two sections, general information on the left and an interactive geographical visualisation scatter plot on the right. The information cards provide up to date information from the COVID-19 dataset. This information can be changed/updated using the controls in the navigation bar. Each information card has an additional tooltip. A tooltip provides additional information on the attribute. Also on the left hand-side is the top six table. The interactive geographical visualisation scatter plot provides an interactive visual aspect to the project. It displays data using a scatter plot graph. Only one attribute is displayed at any one time. The attributes can be changed using the tabs above the scatter map plot. The options are confirmed cases, death cases and case fatality rate. This also updates the data on table. The slider under the scatter map plot allows the user to select a date to view on the map plot. This ranges from the beginning of the COVID-19 pandemic to current day. A description on how to use the slider is located beside it.

The country view GUI consists of two sections, information cards and statistics on the left and interactive line graphs on the right. The information cards provides up to date information from the COVID-19 dataset. This information can be changed/updated using the controls in the navigation bar. Each information card has an additional tooltip also. The statistics table provides additional detailed information on the selected county, such as highest confirmed cases in a single day or even the mean confirmed cases. On the second section of the country view, it is split into four graphs. The first row consists of a map plot of the selected country and a line graph of vaccinations administered. The second row is made up of line graphs for confirmed cases and deaths. All of the graphs/plots are interactive and use the selected countries data from the datasets. 

## Table of Contents

```@contents
```

## Geovisualisation.jl

Geovisualisation.jl contain the Dash web application, including the layout and callbacks.

```@docs
runGeovisualiser()
```

## utils.jl

```@docs
readGlobalConfirmedCSV()
```

```@docs
readGlobalDeathsCSV()
```

```@docs
readGlobalRecoveredCSV()
```

```@docs
readGlobalVaccinationCSV()
```

```@docs
getTotalConfirmedCases(df, country, date)
```

```@docs
getTotalRecoveredCases(df, country, date)
```

```@docs
getTotalDeaths(df, country, date)
```

```@docs
getTotalVaccinations(df, country, date)
```

```@docs
getTotalCaseFatality(df, country, date)
```

```@docs
getTopSixFromDataframe(df)
```

```@docs
getStatisticsTableForCountry(filteredConfirmedData, filteredDeathsData, filteredVaccinationData)
```

```@docs
getCaseFatalityDataframe(confirmedData, deathsData)
```

```@docs
getListOfCountries(df)
```

```@docs
getStartDate(df)
```

```@docs
getEndDate(df)
```

```@docs
formatToDateObject(date)
```

```@docs
convertTimeSeriesData(data)
```

```@docs
prettifyNumberArray(data)
```

```@docs
roundNumberArray(data)

## Index

```@index
```