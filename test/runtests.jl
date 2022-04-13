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
    @test getTotalCaseFatality(caseFatalityRateData, "Ireland", Date("2020-12-30")) == "40.502"

    @time @test getTotalConfirmedCases(confirmedData, "China (Hubei)", Date("2020-01-22")) == "444"
    @test getTotalDeaths(deathsData, "China (Hubei)", Date("2020-01-22")) == "17"
    @test getTotalRecoveredCases(recoveredData, "China (Hubei)", Date("2020-01-22")) == "28"
    @test getTotalVaccinations(vaccinationData, "China (Hubei)", Date("2020-01-22")) == "Pre-vaccination date selected"
    @test getTotalVaccinations(vaccinationData, "China (Hubei)", Date("2020-12-12")) == "No Data Available"
    @test getTotalCaseFatality(caseFatalityRateData, "China (Hubei)", Date("2020-01-22")) == "26.118"
end

@testset "Control Functions" begin
    @test isempty(getListOfCountries(confirmedData)) == false
    @test getStartDate(confirmedData) == Date("2020-01-22")
end

@testset "Utility Functions" begin
    @test formatToDateObject("1/22/20") == Date("2020-01-22")
    
    @test convertTimeSeriesData([1,2,4,8]) == [1,2,4]
    @test convertTimeSeriesData([1,-1,4,8]) == [0,5,4]

end
