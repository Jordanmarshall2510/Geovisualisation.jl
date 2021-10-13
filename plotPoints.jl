using PlotlyJS, Shapefile, GeoInterface, GeoJSON, DataFrames, CSV
using Dash, DashHtmlComponents, DashCoreComponents

sample =    [
                [[1,2], [3,4], [5,6]],
                [[1,2], [3,4], [5,6]],
                [[1,2], [3,4], [5,6]],
            ]

function plotMap()
    trace = scatter(x=xValues, y=yValues, fill="toself")
    layout = Layout(
        autosize=true,
        width=750,
        height=750,
        template=templates["plotly_dark"]
    )

    return plot(trace, layout)
end

function splitToXY(coordinatesArray)
    xArray = Vector{Float64}()
    yArray = Vector{Float64}()

    i = 1
    while i <= length(coordinatesArray)
        j = 1
        while j <= length(coordinatesArray[i])
            k = 1
            while k <= length(coordinatesArray[i][j])
                push!(xArray, coordinatesArray[i][j][k][1])
                push!(yArray, coordinatesArray[i][j][k][2])
                k += 1
            end
            j +=1
        end
        i += 1
    end

    return xArray, yArray
end

# table = Shapefile.Table("counties.shp")
# cords = GeoInterface.coordinates(Shapefile.shape(first(table)))

df = DataFrame(CSV.File("counties.csv"))
print(df)

# xValues, yValues = splitToXY()

# p1 = plotMap()

# app = dash()

# app.layout = html_div(style=Dict("backgroundColor" => "#111111", "margin" => 0, "margin" => 0)) do
#     html_div([
#         html_h1("Geographical Data Visualizer", style=Dict("color" => "#7FDBFF", "textAlign" => "center")),
#         dcc_graph(
#             id = "example-graph-1",
#             figure = p1,
#         ),
#         html_label("Slider"),
#         dcc_slider(
#             min=1,
#             max=10,
#             step=nothing,
#             value=1,
#             marks=Dict([i => ("Label $(i)") for i = 1:10]),
#         )
#     ], style=Dict("marginBottom" => 50, "marginTop" => 25))
# end

# run_server(app, "127.0.0.1", debug=true)