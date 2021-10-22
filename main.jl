using Plots, Shapefile, PlotlyJS
using Dash, DashHtmlComponents, DashCoreComponents

plotlyjs()
shp = Shapefile.shapes(Shapefile.Table("shapefile/counties.shp"))
theme(:dark)
Plots.plot(shp)
p = Plots.plot!(size=(1200,800))

data = Plots.plotly_series(p)
layout = Plots.plotly_layout(p)

# open("index.html", "w") do io
#     show(io, "text/html", p)
# end

app = dash(external_stylesheets = ["assets/style.css"])

app.layout = html_div(style=Dict("backgroundColor" => "#30343b", "margin" => 0, "margin" => 0)) do
    html_div([
        html_h1("Geographical Data Visualizer", style=Dict("color" => "#7FDBFF", "textAlign" => "center")),
        html_div([
            dcc_graph(
                id = "example-graph-1",
                figure = (;data, layout),
            ),
        ]),
        html_div([
            html_label("Slider"),
            dcc_slider(
                min=1,
                max=10,
                step=nothing,
                value=1,
                marks=Dict([i => ("Label $(i)") for i = 1:10]),
            ),
        ]),
    ], style=Dict("marginBottom" => 50, "marginTop" => 25))
    
end

run_server(app, "127.0.0.1", debug=true)