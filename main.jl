using Plots, Shapefile, DataFrames
shp = Shapefile.shapes(Shapefile.Table("counties.shp"))

table = Shapefile.Table("counties.shp")

# example function that iterates over the rows and gathers shapes that meet specific criteria
function selectshapes(table)
    geoms = empty(Shapefile.shapes(table))
    for row in table
        if !ismissing(row.TestDouble) && row.TestDouble < 2000.0
            push!(geoms, Shapefile.shape(row))
        end
    end
    return geoms
end

# the metadata can be converted to other Tables such as DataFrame

df = DataFrame(table)
print(df)

p = plot(shp)