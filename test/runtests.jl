using Geovisualisation
using Test

using Dates

import Humanize: digitsep

include("../src/utils.jl")

confirmedData = readGlobalConfirmedCSV()
deathsData = readGlobalDeathsCSV()
recoveredData = readGlobalRecoveredCSV()
vaccinationData = readGlobalVaccinationCSV()
caseFatalityRateData =  getCaseFatalityDataframe(confirmedData, deathsData)

@testset "Reading data" begin
    @test isempty(confirmedData) == false
    @test isempty(deathsData) == false
    @test isempty(recoveredData) == false
    @test isempty(vaccinationData) == false
    @test isempty(caseFatalityRateData) == false
end
    
@testset "Information Functions" begin
    @test getTotalConfirmedCases(confirmedData, "Ireland", Date("2020-01-22")) == "No Data Available"
    @test getTotalDeaths(deathsData, "Ireland", Date("2020-01-22")) == "No Data Available"
    @test getTotalRecoveredCases(recoveredData, "Ireland", Date("2020-01-22")) == "No Data Available"
    @test getTotalVaccinations(vaccinationData, "Ireland", Date("2020-12-12")) == "No Data Available"
    @test getTotalVaccinations(vaccinationData, "Ireland", Date("2020-01-22")) == "Pre-vaccination date selected"
    @test getTotalCaseFatality(caseFatalityRateData, "Ireland", Date("2020-01-22")) == "No Data Available"
    @test getTotalCaseFatality(caseFatalityRateData, "Ireland", Date("2020-12-30")) == "0.025"

    @test getTotalConfirmedCases(confirmedData, "China (Hubei)", Date("2020-01-22")) == "444"
    @test getTotalDeaths(deathsData, "China (Hubei)", Date("2020-01-22")) == "17"
    @test getTotalRecoveredCases(recoveredData, "China (Hubei)", Date("2020-01-22")) == "28"
    @test getTotalVaccinations(vaccinationData, "China (Hubei)", Date("2020-01-22")) == "Pre-vaccination date selected"
    @test getTotalVaccinations(vaccinationData, "China (Hubei)", Date("2020-12-12")) == "No Data Available"
    @test getTotalCaseFatality(caseFatalityRateData, "China (Hubei)", Date("2020-01-22")) == "0.038"
end

@testset "Control Functions" begin
    @test isempty(getListOfCountries(confirmedData)) == false
    @test issubset([(label = "Global", value = "Global")], getListOfCountries(confirmedData)) == true
    @test issubset([(label = "Ireland", value = "Ireland")], getListOfCountries(confirmedData)) == true
    @test issubset([(label = "Canada (Alberta)", value = "Canada (Alberta)")], getListOfCountries(confirmedData)) == true
    
    @test getStartDate(confirmedData) == Date("2020-01-22")
end

@testset "Utility Functions" begin
    @test formatToDateObject("1/22/20") == Date("2020-01-22")
    @test formatToDateObject("10/31/22") == Date("2022-10-31")
    
    @test convertTimeSeriesData([1,2,4,8]) == [1,2,4]
    @test convertTimeSeriesData([1,-1,4,8]) == [0,5,4]

    @test prettifyNumberArray([100100, 2000]) == ["100,100", "2,000"]
    @test roundNumberArray([1.2345, 2.999999]) == [1.234, 3.0]

end
