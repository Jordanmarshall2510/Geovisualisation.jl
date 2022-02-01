using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents
using PlotlyJS
using Dates
using DataFrames

include("utils.jl")
include("callbacks.jl")

# Read global confirmed cases from repo
confirmedData = readGlobalConfirmedCSV()

# Read global recovered cases from repo
recoveredData = readGlobalRecoveredCSV()

# Read global deaths from repo
deathsData = readGlobalDeathsCSV()

# Read global vaccination from repo
vaccinationData = readGlobalVaccinationCSV()

# Sums total confirmed cases worldwide
totalConfirmedCases = getTotalConfirmedCases(confirmedData)

# Sums total recovered cases worldwide
totalRecoveredCases = getTotalConfirmedCases(recoveredData)

# Sums total deaths worldwide
totalDeaths = getTotalConfirmedCases(deathsData)

# Sums total deaths worldwide
totalVaccinations = getTotalVaccinations(vaccinationData)

# Providing dropdown options of countries
dropdownOptions = getListOfCountries(confirmedData)

# Gets first date of date entry
startDate = getStartDate(confirmedData)

# Gets last date of date entry
endDate = getEndDate(confirmedData)

# Initial Dash application with dark theme
app = dash(external_stylesheets = [dbc_themes.DARKLY], suppress_callback_exceptions=true)

###################
# Search and filter
###################

controls =[
    dbc_col(
        dcc_datepickersingle(
            id = "date-picker",
            min_date_allowed = startDate,
            max_date_allowed = endDate,
            date = endDate,
            display_format="Do MMM YY"
        ),
        width="auto",
    ),

    dbc_col(
        dcc_dropdown(
            id="countries-dropdown",
            options = dropdownOptions,
            value="Global",
            style = Dict("color" => "black"),
        ),
        width="5",
    ), 
]

###################
# Information Cards
###################

information = [
    dbc_card(
        [
            dbc_cardbody([
                html_h5("Confirmed Cases", className = "card-title"),
                html_h6(totalConfirmedCases),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Recovered Cases", className = "card-title"),
                html_h6(totalRecoveredCases),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Deaths", className = "card-title"),
                html_h6(totalDeaths),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Vaccines Administered", className = "card-title"),
                html_h6(totalVaccinations),
            ]),
        ],
        body=true,
    ),
]

###################
# Scatter Map Graph
###################

# Refer to https://plotly.com/javascript/mapbox-layers/ for mapbox parameters

globalMap=[
    dcc_graph(
        id = "graph-mapbox-plot",
        style = Dict("height"=>"75vh"),
    ),

    html_hr(),

    dcc_slider(
        id="map-slider",
        min=5,
        max=ncol(confirmedData),
        step=1,
        value=ncol(confirmedData),
        tooltip=Dict("placement"=> "bottom", "always_visible"=>true),
        updatemode="drag",
    ),
]

countryGraphs=[
    dbc_row([
        dbc_col(
            dcc_graph(),
            width=5,
        ),
        dbc_col(
            dcc_graph(),
            width=5,

        )
    ], justify = "center"),

    html_hr(),

    dbc_row([
        dbc_col(
            dcc_graph(),
            width=5,
        ),
        dbc_col(
            dcc_graph(),
            width=5,
        )
    ], justify = "center"),
]

app.layout = dbc_container(
    [
        dbc_row(
            dbc_col(html_h3("COVID-19 Geographical Visualiser"), width="auto"),
            justify="center",
        ),
        html_hr(),
        dbc_row(controls, justify = "center"),
        html_hr(),
        dbc_row(
            [
                dbc_col(information, width=3),
                dbc_col(id="graphs", width=9),
            ], 
            align="center",
        ),
    ],
    fluid=true,
)

###################################
# Callbacks
###################################

callback!(
    app,
    Output("graphs", "children"),
    Input("countries-dropdown", "value"),
) do  country
    if country == "Global"
        return globalMap
    else
        return countryGraphs
    end
end

# Change graph using slider.
callback!(
    app, 
    Output("graph-mapbox-plot", "figure"), 
    Input("map-slider", "value")
    ) do sliderInput
    figure = (
        data = [
            (
                hovertext = confirmedData."Country/Region",
                lon = confirmedData."Long", 
                lat = confirmedData."Lat",
                type = "scattermapbox", 
                marker = Dict(
                    "color"=>"blue", 
                    "size" => (confirmedData[!, sliderInput]/findmax(confirmedData[!, sliderInput])[1])*300,
                ),
                name = "m1", 
                mode = "markers",
            ),
        ],
        layout = (
            mapbox = Dict("style"=>"open-street-map"),
            margin=Dict("r"=>0,"t"=>0,"l"=>0,"b"=>0),
        )
    )
    return figure
end

###################################
# Run Server
###################################

run_server(app, "127.0.0.1", dev_tools_hot_reload=true, debug=true)