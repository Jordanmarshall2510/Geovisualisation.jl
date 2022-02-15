module Geovisualisation

using Dash
using DashBootstrapComponents
using PlotlyJS
using Dates
using DataFrames

include("utils.jl")

# Read global confirmed cases from repo
confirmedData = readGlobalConfirmedCSV()

# Read global recovered cases from repo
recoveredData = readGlobalRecoveredCSV()

# Read global deaths from repo
deathsData = readGlobalDeathsCSV()

# Read global vaccination from repo
vaccinationData = readGlobalVaccinationCSV()

# Providing dropdown options of countries
dropdownOptions = getListOfCountries(confirmedData)

# Gets first date of date entry
startDate = getStartDate(confirmedData)

# Gets last date of date entry
endDate = getEndDate(confirmedData)

caseFatility = getCaseFatalityDataframe(confirmedData, deathsData)

# Initial Dash application with dark theme
app = dash(external_stylesheets = [dbc_themes.DARKLY, dbc_icons.BOOTSTRAP], suppress_callback_exceptions=true)

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
    html_h3(id="info-title"),

    html_hr(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Confirmed Cases", className = "card-title"),
                html_h6(id="totalConfirmedCases"),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Recovered Cases", className = "card-title"),
                html_h6(id="totalRecoveredCases"),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Deaths", className = "card-title"),
                html_h6(id="totalDeaths"),
            ]),
        ],
        body=true,
    ),

    html_br(),

    dbc_card(
        [
            dbc_cardbody([
                html_h5("Vaccines Administered", className = "card-title"),
                html_h6(id="totalVaccinations"),
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

    dbc_tabs(
        [
            dbc_tab(label = "Confirmed Cases", tab_id = "confirmed-tab"),
            dbc_tab(label = "Death Cases", tab_id = "death-tab"),
            dbc_tab(label = "Case Fatility", tab_id = "case-fatility-tab"),
        ],
        id = "tabs",
        active_tab = "confirmed-tab",
    ),

    dcc_graph(
        id = "graph-mapbox-plot",
        style = Dict("height"=>"70vh"),
    ),

    html_hr(),

    # dcc_interval(
    #     id="auto-stepper",
    #     interval=1*250, # in milliseconds
    #     n_intervals=0
    # ),

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
            dcc_graph(
                id="country-map",
                style = Dict("height"=>"40vh"),
            ),
            width=5,
        ),
        dbc_col(
            dcc_graph(
                id="country-vaccination-graph",
                style = Dict("height"=>"40vh"),
            ),
            width=5,

        )
    ], justify = "center"),

    html_hr(),

    dbc_row([
        dbc_col(
            dcc_graph(
                id="country-confirmed-graph",
                style = Dict("height"=>"40vh"),
            ),
            width=5,
        ),
        dbc_col(
            dcc_graph(
                id="country-deaths-graph",
                style = Dict("height"=>"40vh"),
            ),
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

# Change between global and country views
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

# callback!(
#     app,
#     Output("map-slider", "value"),
#     Input("auto-stepper", "n_intervals"),
# )do n_intervals
#     if isnothing(n_intervals)
#         return 0
#     else
#         return (n_intervals+1) % ncol(confirmedData)
#     end
# end

# Update information cards
callback!(
    app,
    Output("info-title", "children"),
    Output("totalConfirmedCases", "children"),
    Output("totalRecoveredCases", "children"),
    Output("totalDeaths", "children"),
    Output("totalVaccinations", "children"),
    Input("date-picker", "date"),
    Input("countries-dropdown", "value"),

) do date, country
    if (isnothing(country) == false)
        date = Date(date)
        title = country * " -\t As of " * string(Dates.format(date, "dd u yyyy"))
        return title, getTotalConfirmedCases(confirmedData, country, date), getTotalRecoveredCases(recoveredData, country, date), getTotalDeaths(deathsData, country, date), getTotalVaccinations(vaccinationData, country, date)
    else
        return "Please select an option from the dropdown menu", "No Data Available", "No Data Available", "No Data Available", "No Data Available"
    end
end

# Change graph using slider.
callback!(
    app, 
    Output("graph-mapbox-plot", "figure"), 
    Input("map-slider", "value"),
    Input("tabs", "active_tab"),
    ) do sliderInput, tab
    if tab == "confirmed-tab"
        dataset = confirmedData
        colour = "blue"
    elseif tab == "death-tab"
        dataset = deathsData
        colour = "black"
    elseif tab == "case-fatility-tab"
        dataset = caseFatility
        colour = "red"
    end
    
    figure = (
        data = [
            (
                hovertext = dataset."Country/Region",
                lon = dataset."Long", 
                lat = dataset."Lat",
                type = "scattermapbox", 
                marker = Dict(
                    "color"=> colour, 
                    "size" => (dataset[!, sliderInput]/findmax(dataset[!, sliderInput])[1])*150,
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

# Changes country graphs on selection
callback!(
    app,
    Output("country-map", "figure"),
    Output("country-vaccination-graph", "figure"),
    Output("country-confirmed-graph", "figure"),
    Output("country-deaths-graph", "figure"),
    Input("countries-dropdown", "value"),
) do region
    if (isnothing(region) == false) && (region != "Global")
        filteredConfirmedData = filter(df -> (df."Country/Region" == region), confirmedData)
        filteredDeathsData = filter(df -> (df."Country/Region" == region), deathsData)
        filteredVaccinationData = filter(df -> (df."Country/Region" == region), vaccinationData)
        
        map = figure = (
            data = [
                (
                    hovertext = filteredConfirmedData."Country/Region",
                    lon = [filteredConfirmedData."Long"[1]], 
                    lat = [filteredConfirmedData."Lat"[1]],
                    type = "scattermapbox", 
                    marker = Dict(
                        "color"=>"red", 
                        "size" => 15,
                    ),
                    name = "m1", 
                    mode = "markers",
                ),
            ],
            layout = (
                mapbox = Dict(
                    "zoom"=>5, 
                    "center"=>(
                        lon = filteredConfirmedData."Long"[1], 
                        lat = filteredConfirmedData."Lat"[1],
                    ),
                    "style"=>"open-street-map",
                ),
                margin=Dict("r"=>0,"t"=>0,"l"=>0,"b"=>0),
            )
        )
        
        confirmedGraph = Plot(
            [scatter(
                x=names(filteredConfirmedData[!, 5:ncol(filteredConfirmedData)]),
                y=collect(filteredConfirmedData[!, 5:ncol(filteredConfirmedData)][1,:])
                )
            ], 
            Layout(
                title="Confirmed Cases Time Series",
                # plot_bgcolor = "#222",
                # paper_bgcolor = "#222",
            )
        )

        deathsGraph = Plot(
            [scatter(
                x=names(filteredDeathsData[!, 5:ncol(filteredDeathsData)]),
                y=collect(filteredDeathsData[!, 5:ncol(filteredDeathsData)][1,:])
                )
            ], 
            Layout(
                title="Death Cases Time Series",
                # plot_bgcolor = "#222",
                # paper_bgcolor = "#222",
            )
        )

        vaccinationGraph = Plot(
            [scatter(
                x=names(filteredVaccinationData[!, 5:ncol(filteredVaccinationData)]),
                y=collect(filteredVaccinationData[!, 5:ncol(filteredVaccinationData)][1,:])
                )
            ], 
            Layout(
                title="Vaccination Time Series",
                # plot_bgcolor = "#222",
                # paper_bgcolor = "#222",
            )
        )

        return map, confirmedGraph, vaccinationGraph, deathsGraph
    end
    return no_update(), no_update(), no_update(), no_update()
end

###################################
# Run Server
###################################

run_server(app, "127.0.0.1", dev_tools_hot_reload=true, debug=true)    

end # module
