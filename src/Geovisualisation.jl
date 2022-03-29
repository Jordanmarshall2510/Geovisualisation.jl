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

# Calculate case fatality data from confirmed and death data
caseFatalityData = getCaseFatalityDataframe(confirmedData, deathsData)

# Providing dropdown options of countries
dropdownOptions = getListOfCountries(confirmedData)

# Gets first date of date entry
startDate = getStartDate(confirmedData)

# Gets last date of date entry
endDate = getEndDate(confirmedData)

# Initial Dash application with dark theme
app = dash(external_stylesheets = [dbc_themes.DARKLY, dbc_icons.BOOTSTRAP], suppress_callback_exceptions=true)

###################
# Search and filter
###################

controls = dbc_row(
    [
        dbc_col(
            dbc_select(
                id="countries-dropdown",
                options = dropdownOptions,
                value="Global",
                style = Dict("color" => "black", "height" => "48px"),
            ),
            width="6",
        ), 

        dbc_col(
            dcc_datepickersingle(
                id = "date-picker",
                min_date_allowed = startDate,
                max_date_allowed = endDate,
                date = endDate,
                display_format="Do MMM YY",
            ),
            style = Dict("padding-left" => "10px"),
            width="6",
        ),
    ],
)

###################
# Information Cards
###################

information = [
    dbc_row(
        html_h5(id="info-title"),
        style=Dict("height"=> "5%"),
    ),

    dbc_row(
        [
            dbc_card(
                dbc_cardbody([
                    html_h5("Confirmed Cases", className = "card-title"),
                    html_h6(id="totalConfirmedCases"),
                ]),
                id = "confirmedTooltip",
            ),
            dbc_tooltip(
                "Confirmed cases is the total amount of individuals that were infected by COVID-19.",
                target = "confirmedTooltip",
            ),
        ],
        style=Dict("height"=> "15%"),
    ),

    dbc_row(style=Dict("height"=> "2.5%")),

    dbc_row(
        [
            dbc_card(
                dbc_cardbody([
                    html_h5("Recovered Cases", className = "card-title"),
                    html_h6(id="totalRecoveredCases"),
                ]),
                id = "recoveredTooltip",
            ),
            dbc_tooltip(
                "Recovered cases is the total amount of individuals that were infected by COVID-19 and are now fully recovered from the disease.",
                target = "recoveredTooltip",
            ),
        ],
        style=Dict("height"=> "15%"),
    ),

    dbc_row(style=Dict("height"=> "2.5%")),

    dbc_row(
        [
            dbc_card(
                dbc_cardbody([
                    html_h5("Deaths", className = "card-title"),
                    html_h6(id="totalDeaths"),
                ]),
                id = "deathsTooltip",
            ),
            dbc_tooltip(
                "Deaths is the total amount of individuals that passed away due to being infected by COVID-19.",
                target = "deathsTooltip",
            ),
        ],
        style=Dict("height"=> "15%"),
    ),

    dbc_row(style=Dict("height"=> "2.5%")),

    dbc_row(
        [
            dbc_card(
                dbc_cardbody([
                    html_h5("Vaccines Administered", className = "card-title"),
                    html_h6(id="totalVaccinations"),
                ]),
                id = "vaccinesTooltip",
            ),
            dbc_tooltip(
                "Vaccines administered is the total amount of vaccines administered to individuals.",
                target = "vaccinesTooltip",
            ),
        ],
        style=Dict("height"=> "15%"),
    ),

    dbc_row(style=Dict("height"=> "2.5%")),

    dbc_row(
        [
            dbc_card(
                dbc_cardbody([
                    html_h5("Case Fatality Rate", className = "card-title"),
                    html_h6(id="totalCaseFatality"),
                ]),
                id = "caseFatalityRateTooltip",
            ),
            dbc_tooltip(
                "Case fatality rate is the proportion of people diagnosed with COVID-19 who die from that disease.",
                target = "caseFatalityRateTooltip",
            ),
        ],
        style=Dict("height"=> "15%"),
    ),

    dbc_row(
        dbc_col(
            html_h6(id="slider-instructions"),
        ),
        align="center",
        style=Dict("height"=> "10%"),
    ),
]

###################
# Scatter Map Graph
###################

globalMap=[
    dbc_row(
        dbc_tabs(
            [
                dbc_tab(label = "Confirmed Cases", tab_id = "confirmed-tab"),
                dbc_tab(label = "Death Cases", tab_id = "death-tab"),
                dbc_tab(label = "Case Fatality Rate", tab_id = "case-fatality-tab"),
            ],
            id = "tabs",
            active_tab = "confirmed-tab",
        ),
        style=Dict("height"=> "5%"),
    ),
    
    dbc_row(
        dcc_graph(
            id = "graph-mapbox-plot",
        ),
        style=Dict("height"=> "85%"),
    ),

    dbc_row(
        dbc_col(
            html_div(id="selected-value-slider"),
            width="auto"
        ),
        justify = "center",
        style=Dict("height"=> "5%"),
    ),

    dbc_row(
        dbc_col(
            dcc_slider(
                id="map-slider",
                min=5,
                max=size(confirmedData,2),
                step=1,
                value=size(confirmedData,2),
                updatemode="drag",
            ),
            width=12,
        ),
        style=Dict("height"=> "5%"),
    ),
]

countryGraphs=[
    dbc_row(
        [
            dbc_col(
                html_h5("Country"),
                width=6,
            ),
            dbc_col(
                html_h5("Vaccination Administered"),
                width=6,
            ),
        ],
        style = Dict("height"=>"5%"),
    ),

    dbc_row(
        [
            dbc_col(
                dcc_loading(
                type="default",
                    children=[
                        dcc_graph(
                            id="country-map",
                            style = Dict("height"=>"35vh"),
                        )
                    ],
                ),
                width=6,
            ),
            dbc_col(
                dcc_loading(
                    type="default",
                    children=[
                        dcc_graph(
                            id="country-vaccination-graph",
                            style = Dict("height"=>"35vh"),
                        )
                    ],
                ),
                width=6,
            ),
        ],
        style = Dict("height"=>"40%"),
    ),

    dbc_row(
        [
            dbc_col(
                html_h5("Confirmed Cases"),
                width=6,
            ),
            dbc_col(
                html_h5("Deaths"),
                width=6,
            ),
        ],
        style = Dict("height"=>"5%"),
    ),

    dbc_row(
        [
            dbc_col(
                dcc_loading(
                    type="default",
                    children=[
                        dcc_graph(
                            id="country-confirmed-graph",
                            style = Dict("height"=>"36vh"),
                        )
                    ],
                ),
                width=6,
            ),
            dbc_col(
                dcc_loading(
                    type="default",
                    children=[
                        dcc_graph(
                            id="country-deaths-graph",
                            style = Dict("height"=>"36vh"),
                        )
                    ],
                ),
                width=6,
            ),
        ],
        style = Dict("height"=>"40%"),
    ),

    dbc_row(
        style = Dict("height"=>"10%"), 
    ),
]

app.layout = dbc_container(
    [
        # Navbar
        dbc_row(
            [
                dbc_col(
                    html_h3("COVID-19 Geovisualiser"),
                    width=3,
                ),
                dbc_col(
                    html_h6("Data provided by Center for Systems Science and Engineering (CSSE) at Johns Hopkins University"),
                    width=5,
                ),
                dbc_col(
                    controls,
                    width=4,
                ),
            ],
            align="center",
            style = Dict("height"=>"6%", "padding-left" => "1%", "background-color"=> "blue"),
        ),
        
        # Body
        dbc_row(
            [
                dbc_col(
                    information, 
                    width=3,
                    style=Dict("height"=> "100%", "padding-right"=>"2%"),
                ),
                dbc_col(
                    id="graphs",
                    width=9,
                    style=Dict("height"=> "100%"),
                ),
            ], 
            style = Dict("height"=>"94%", "padding"=>"1%"),
        ),
    ],
    style = Dict("height"=>"100vh"),
    fluid=true,
)

###################################
# Callbacks
###################################

# Change between global and country views
callback!(
    app,
    Output("graphs", "children"),
    Output("slider-instructions", "children"),
    Input("countries-dropdown", "value"),
) do  country
    if country == "Global"
        return globalMap, "Drag the slider to interact with the COVID-19 global scatter plot. Select one of the tabs above the plot to change the data attribute"
    else
        return countryGraphs, ""
    end
end

# Update information cards
callback!(
    app,
    Output("info-title", "children"),
    Output("totalConfirmedCases", "children"),
    Output("totalRecoveredCases", "children"),
    Output("totalDeaths", "children"),
    Output("totalVaccinations", "children"),
    Output("totalCaseFatality", "children"),
    Input("date-picker", "date"),
    Input("countries-dropdown", "value"),

) do date, country
    if (isnothing(country) == false && isnothing(date) == false)
        date = Date(date)
        title = country * " -\t As of " * string(Dates.format(date, "dd u yyyy"))
        return  title, 
                getTotalConfirmedCases(confirmedData, country, date),
                getTotalRecoveredCases(recoveredData, country, date),
                getTotalDeaths(deathsData, country, date),
                getTotalVaccinations(vaccinationData, country, date),
                getTotalCaseFatality(caseFatalityData, country, date)
    else
        return  "Please select an option from the dropdown menu",
                "No Data Available",
                "No Data Available",
                "No Data Available",
                "No Data Available",
                "No Data Available"
    end
end

# Change graph using slider.
callback!(
    app, 
    Output("graph-mapbox-plot", "figure"),
    Output("selected-value-slider", "children"), 
    Input("map-slider", "value"),
    Input("tabs", "active_tab"),
    ) do sliderInput, tab
    if tab == "confirmed-tab"
        dataset = confirmedData
        colour = "blue"
    elseif tab == "death-tab"
        dataset = deathsData
        colour = "black"
    elseif tab == "case-fatality-tab"
        dataset = caseFatalityData
        colour = "red"
    end

    sliderDict = Dict(collect(4:size(confirmedData,2)) .=> names(confirmedData)[4:size(confirmedData,2)])
    sliderDate = Date(sliderDict[sliderInput], "mm/dd/yy")
    sliderDateFormat = Dates.format(sliderDate, "dd U yy")

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
    return figure, "Selected Date: " * sliderDateFormat
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
                x=names(filteredConfirmedData[!, 4:end]),
                y=convertTimeSeriesData(collect(filteredConfirmedData[!, 4:end][1,:]))
                )
            ], 
        )

        deathsGraph = Plot(
            [scatter(
                x=names(filteredDeathsData[!, 4:end]),
                y=convertTimeSeriesData(collect(filteredDeathsData[!, 4:end][1,:]))
                )
            ], 
        )
        
        filteredVaccinationData = filter(df -> (df."Country/Region" == region), vaccinationData)
        if(size(filteredVaccinationData, 1) > 0)
            vaccinationGraph = Plot(
                [scatter(
                    x=names(filteredVaccinationData[!, 4:end]),
                    y=convertTimeSeriesData(collect(filteredVaccinationData[!, 4:end][1,:]))
                    )
                ], 
            )

            return map, vaccinationGraph, confirmedGraph, deathsGraph
        else
            return map, no_update(), confirmedGraph, deathsGraph
        end
    end
    return no_update(), no_update(), no_update(), no_update()
end

###################################
# Run Server
###################################

# Runs local server. Call in REPL.
function runGeovisualiser()
    run_server(app, "127.0.0.1", dev_tools_hot_reload=true, debug=true)     
end

end # module
