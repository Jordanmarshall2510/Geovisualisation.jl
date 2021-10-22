using Plots, Shapefile
using Dash, DashHtmlComponents, DashCoreComponents

plotly()
shp = Shapefile.shapes(Shapefile.Table("counties.shp"))
plot(shp)
p1 = plot!(size=(1200,800))

# open("index.html", "w") do io
#     show(io, "text/html", p1)
# end

app = dash()

app.layout = html_div(style=Dict("backgroundColor" => "#111111", "margin" => 0, "margin" => 0)) do
    html_div([
        html_h1("Geographical Data Visualizer", style=Dict("color" => "#7FDBFF", "textAlign" => "center")),
        dcc_graph(
            id = "example-graph-1",
            figure = p1,
        ),
        html_label("Slider"),
        dcc_slider(
            min=1,
            max=10,
            step=nothing,
            value=1,
            marks=Dict([i => ("Label $(i)") for i = 1:10]),
        )
    ], style=Dict("marginBottom" => 50, "marginTop" => 25))
end

run_server(app, "127.0.0.1", debug=true)