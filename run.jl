using Dash, DashHtmlComponents, DashCoreComponents, DashVtk, PlotlyJS

content = plot(scatter(x=[0,1,2,0], y=[0,2,0,0], fill="toself"))


app = dash()

dropdown_options = [
    Dict("label" => "New York City", "value" => "NYC"),
    Dict("label" => "Montreal", "value" => "MTL"),
    Dict("label" => "San Francisco", "value" => "SF"),
]
app.layout = html_div(style=Dict("backgroundColor" => "#111111")) do
    html_div(
    style = Dict(
          "width" => "100%",
          "height" => "400px",
    ),
    children=[content]
    ),
    html_label("Dropdown"),
    dcc_dropdown(options = dropdown_options, value = "MTL"),
    html_label("Multi-Select Dropdown"),
    html_label("Radio Items"),
    dcc_radioitems(options = dropdown_options, value = "MTL"),
    html_label("Slider"),
    dcc_slider(
        min = 0,
        max = 9,
        marks = Dict([i => (i == 1 ? "Label $(i)" : "$(i)") for i = 1:6]),
        value = 5,
    )
end

run_server(app, "0.0.0.0", 8080, debug = true)