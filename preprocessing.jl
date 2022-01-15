using DataFrames
using CSV
using HTTP

url = HTTP.get("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/01-01-2021.csv")
data = CSV.read(url.body, DataFrame)
println(data[1, :])
println("done")
