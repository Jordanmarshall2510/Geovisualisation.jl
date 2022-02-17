# COVID-19 Geovisualisation

COVID-19 Geovisualisation provides easy to understand Coronavirus data, visualised on a dashboard. Data is updated daily by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University.

## Features

- Displays daily and total figures for confirmed cases, recovered cases, deaths and vaccinations for both worldwide or a specified country/region.
- Display a global scatter map comparing country's confirmed cases, recovered cases, or case fatility rate.
- Display time-series data for specified country.
- Ability to select a date to view data.
- Ability to select a country/region to view data.

## Tech

COVID-19 Geovisualisation uses a number of languages, tools and frameworks to work properly:

- [Julia](https://julialang.org/) - High-level and high-performing programming language.
- [Dash](https://plotly.com/dash/) - A framework used to create interactive web applications.
- [Plotly](https://plotly.com/) - A framework used to create interactive graphs.
- [Dash Bootstrap](https://dash-bootstrap-components.opensource.faculty.ai/) - A library to use Bootstrap features in Dash
- [GitHub](https://github.com/Jordanmarshall2510/FYP-Geographical-Data-Visualiser) - Used for version control

## Run

This web application must be run in the Julia REPL. The repository must first be cloned:
```
git clone https://github.com/Jordanmarshall2510/FYP-Geographical-Data-Visualiser.git
```

Initialise the Julia REPL environment using the Project.toml file:
```
julia --project=.
```

Resolve and instatiate environment dependencies. :
```
julia> ]
(Geovisualisation) pkg> resolve
(Geovisualisation) pkg> instantiate
```

Import the Geovisualisation module:
```
julia> import Geovisualisation
```

Run application on local server:
```
julia> Geovisualisation.runGeovisualiser()
```

Go to web address to view in browser:
```
http://127.0.0.1:8050/
```

## Testing

To run unit tests:
```
julia> ]
(Geovisualisation) pkg> test
```

## Author
### Jordan Marshall ###
4th Year LM051 Computer Systems
