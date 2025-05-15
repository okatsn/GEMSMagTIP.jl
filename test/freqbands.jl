@testset "freqbands.jl" begin
    @test GEMSMagTIP.FreqBandDict()["BP-35"] == GEMSMagTIP.FreqBandDict()["BP_35"] == (0.00032, 0.0178)
    @test GEMSMagTIP.FreqBandDict()["ULF-B"] == GEMSMagTIP.FreqBandDict()["ULF_B"] == (0.001, 0.01)

    @test_throws MethodError GEMSMagTIP.freq_bands["ULF_B"] = (999, 999)
    @test_throws MethodError GEMSMagTIP.freq_bands_ext["ULF_B"] = (999, 999)
    @test GEMSMagTIP.FreqBandDict()["ULF-B"] == GEMSMagTIP.FreqBandDict()["ULF_B"] == (0.001, 0.01)
end
