using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents
using PlotlyJS
using Dates
using DataFrames

include("src/dataProcessing.jl")

# Read global confirmed cases from repo
confirmedData = readGlobalConfirmedCSV()

# Read global recovered cases from repo
recoveredData = readGlobalRecoveredCSV()

# Read global deaths from repo
deathsData = readGlobalDeathsCSV()

# Sums total confirmed cases worldwide
totalConfirmedCases = getTotalConfirmedCases(confirmedData)

# Sums total recovered cases worldwide
totalRecoveredCases = getTotalConfirmedCases(recoveredData)

# Sums total deaths worldwide
totalDeaths = getTotalConfirmedCases(deathsData)

# Providing dropdown options of countries
dropdownOptions = getListOfCountries(confirmedData)

# Gets first date of date entry
startDate = getStartDate(confirmedData)

# Gets last date of date entry
endDate = getEndDate(confirmedData)

# Initial Dash application with dark theme
app = dash(external_stylesheets = [dbc_themes.DARKLY])

###################
# Search and filter
###################

controls =[
    dbc_col(
        dcc_datepickersingle(
            min_date_allowed = startDate,
            max_date_allowed = endDate,
            date = endDate,
            display_format="Do MMM YY"
        ),
        width="auto",
    ),

    dbc_col(
        dcc_dropdown(
            options = dropdownOptions,
            value = "MTL",
            style = Dict("color" => "black"),
        ),
        width="2",
    ),

    dbc_col(
        dcc_slider(
            min=0,
            max=100000,
            step=nothing,
            value=1,
            marks=Dict(
                0 => Dict("label"=> "0 Cases"),
                25000 => Dict("label"=> "25000 Cases"),
                50000 => Dict("label"=> "50000 Cases"),
                75000 => Dict("label"=> "75000 Cases"),
                100000 => Dict("label"=> "100000 Cases"),
            )
        ),
        width="4",
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
                html_h6(totalConfirmedCases),
            ]),
        ],
        body=true,
    ),
]

###################
# Scatter Map Graph
###################

# Refer to https://plotly.com/javascript/mapbox-layers/ for mapbox parameters

map=dcc_graph(
    id = "graph-mapbox-plot",
    figure = (
        data = [
            (
                hovertext = confirmedData."Country/Region",
                hoverlabel = confirmedData[!, ncol(confirmedData)],
                lon = confirmedData."Long", 
                lat = confirmedData."Lat",
                type = "scattermapbox", 
                marker = Dict(
                    "color"=>"blue", 
                    "size" => (confirmedData[!, ncol(confirmedData)]/findmax(confirmedData[!, ncol(confirmedData)])[1])*300,
                ),
                hoverinfo = "y",
                # marker_size = confirmedData[!, ncol(confirmedData)],
                # colorscale = confirmedData[!, ncol(confirmedData)],
                # hoverinfo = confirmedData."Country/Region",
                name = "m1", 
                mode = "markers",
            ),
        ],
        layout = (
            mapbox = Dict("style"=>"open-street-map"),
            margin=Dict("r"=>0,"t"=>0,"l"=>0,"b"=>0),
        )
    ),
    style = Dict("height"=>"81vh"),
)

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
                dbc_col(map, width=9),
            ], 
            align="center",
        ),
    ],
    fluid=true,
)

###################################
# Run Server
###################################

run_server(app, "127.0.0.1", dev_tools_hot_reload=true, debug=true)