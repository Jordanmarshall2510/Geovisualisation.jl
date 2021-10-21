using PlotlyJS, Shapefile, GeoInterface, DataFrames, CSV
using Dash, DashHtmlComponents, DashCoreComponents

function plotMap(xValues, yValues)
    trace = scatter(x=xValues, y=yValues, fill="toself", color="rgba(152, 0, 0, 0.8)")
    layout = Layout(
        autosize=true,
        width=750,
        height=750,
        template=templates["plotly_dark"]
    )

    return plot(trace, layout)
end

function splitTest(df)

    xArray = Vector{Float64}()
    yArray = Vector{Float64}()

    i = 1
    while i <= nrow(df)
        temp_df = df[i,"WKT"]
        if !(occursin("MULTIPOLYGON", temp_df))
            # println(string(i) * "/" * string(nrow(df)))
            temp_df = replace(temp_df, "POLYGON ((" => "")
            temp_df = replace(temp_df, "))" => "")
            temp_df = split(temp_df, ",")

            j = 1
            while j <= length(temp_df)
                temp = split(temp_df[j], " ")
                push!(xArray, parse(Float64,temp[1]))
                push!(yArray, parse(Float64,temp[2]))
                j +=1
            end

        elseif occursin("MULTIPOLYGON", temp_df)
            # temp_df = replace(temp_df, "MULTIPOLYGON " => "")
            # temp_df = chop(temp_df, head = 1, tail = 2)
            # temp_df = split(temp_df, ")),")
        
            # formatted_multipolygon = []
        
            # j = 1
            # while j <= length(temp_df)
            #     temp = chop(temp_df[j], head = 2)
            #     push!(formatted_multipolygon,temp)
            #     j +=1
            # end
            
            # k = 1
            # while k <= length(formatted_multipolygon)
            #     XYcords = split(formatted_multipolygon[k], ",")
            #     XYsplit = split(XYcords, " ")
            #     # push!(xArray, parse(Float64,XYsplit[1]))
            #     # push!(yArray, parse(Float64,XYsplit[2]))
            #     k +=1
            # end
        end
        i += 1
    end
    
    return xArray, yArray
end

df = DataFrame(CSV.File("counties.csv"))


xValues, yValues = splitTest(df)

p1 = plotMap(xValues, yValues)

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