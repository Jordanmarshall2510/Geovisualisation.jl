using Geovisualisation
using Test

using Dates

import Humanize: digitsep

include("../src/utils.jl")

confirmedData = readGlobalConfirmedCSV()
deathsData = readGlobalDeathsCSV()
recoveredData = readGlobalRecoveredCSV()
vaccinationData = readGlobalVaccinationCSV()

@testset "Reading data" begin
    @test isempty(confirmedData) == false
    @test isempty(deathsData) == false
    @test isempty(recoveredData) == false
    @test isempty(vaccinationData) == false
end
    
@testset "Information Functions" begin
    @test getTotalConfirmedCases(confirmedData, "Ireland", Date("2020-01-22")) == digitsep(0)
    @test getTotalDeaths(deathsData, "Ireland", Date("2020-01-22")) == digitsep(0)
    @test getTotalRecoveredCases(recoveredData, "Ireland", Date("2020-01-22")) == digitsep(0)
    @test getTotalVaccinations(vaccinationData, "Ireland", Date("2020-12-12")) == digitsep(0)
end

@testset "Graph Functions" begin
    @test isempty(getCaseFatalityDataframe(confirmedData, deathsData)) == false
end

@testset "Control Functions" begin
    @test isempty(getListOfCountries(confirmedData)) == false
    @test getStartDate(confirmedData) == Date("2020-01-22")
end

@testset "Utility Functions" begin
    @test formatToDateObject("1/22/20") == Date("2020-01-22")
end
