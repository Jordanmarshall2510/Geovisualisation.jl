
using Dash, DashHtmlComponents, DashCoreComponents, DashBootstrapComponents, PlotlyJS, Dates

app = dash(external_stylesheets = [dbc_themes.DARKLY])

app.layout = dbc_container([
    dbc_row(
        dbc_col(html_h2("COVID-19 Geographical Visualiser"), width="auto"),
        justify="center"
    ),

    # Filter
    dbc_row([
        dbc_card([
            dbc_cardbody([
                dbc_row([
                    dbc_col(
                        dcc_dropdown(
                            id="demo-dropdown",
                            options = [
                                (label = "New York City", value = "NYC"),
                                (label = "Montreal", value = "MTL"),
                                (label = "San Francisco", value = "SF")
                            ],
                            value = "MTL",
                        ),
                    ),
                    dbc_col(
                        dcc_slider(
                            id="my-slider-1",
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
                    ),
                    dbc_col(
                        dcc_datepickersingle(
                            id="date-picker-single-example",
                            min_date_allowed = Date(1995, 8, 5),
                            max_date_allowed = Date(2017, 9, 10),
                            initial_visible_month= Date(2017, 8, 5),
                            date = Date(2017, 8, 25)
                        ),
                    ),
                ]),
            ]),
        ]), 
    ], className="p-3", justify = "center"),

    dbc_row([
        # Left-hand column
        dbc_col([
            dbc_card([
                dbc_cardbody([
                    html_h4("Confirmed Cases", className = "card-title"),
                    html_p(
                        "Some quick example text to build on the card title and " *
                        "make up the bulk of the card's content.",
                        className = "card-text",
                    ),
                ]),
            ]), 

            dbc_card([
                dbc_cardbody([
                    html_h4("Recovered Cases", className = "card-title"),
                    html_p(
                        "Some quick example text to build on the card title and " *
                        "make up the bulk of the card's content.",
                        className = "card-text",
                    ),
                ]),
            ]),

            dbc_card([
                dbc_cardbody([
                    html_h4("Deaths", className = "card-title"),
                    html_p(
                        "Some quick example text to build on the card title and " *
                        "make up the bulk of the card's content.",
                        className = "card-text",
                    ),
                ]),
            ]), 

        ], width=3),

        # Right-hand column
        dbc_col([
            dcc_graph(
                id = "graph-mapbox-plot",
                figure = (
                    data = [
                        (lon = [145.1466232, 145.1489419, 145.1489618], lat = [-37.8868434, -37.8871689, -37.8870577], type = "scattermapbox", name = "m1", mode = "markers"),
                    ],
                    layout = (
                            height=800,
                            mapbox = Dict("zoom"=>10, "center"=>(lon=145.14662, lat=-37.88), 
                            "style"=>"open-street-map"))
                )
            )
        ], width=9)
    ]),
], className="p-3", fluid=true)

run_server(app, "127.0.0.1", debug=true)