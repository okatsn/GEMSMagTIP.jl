using Serde
using GEMSMagTIP
using Dates
using JSON

csv_bestmodel = """
Mc,Rc,NthrRatio,Tthr,Tobs,Tpred,Tlead,Athr,Lat,Lon,prp,frc,stn,AlarmedRate,MissedRate,FittingDegree
5,50,0.001,2,5,1,5,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.217913204062789,0.0,0.782086795937211
5,60,0.001,2,5,1,5,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.217913204062789,0.0,0.782086795937211
5,50,0.001,2,5,1,15,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.219944082013048,0.0,0.780055917986953
5,60,0.001,2,5,1,15,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.219944082013048,0.0,0.780055917986953
5,50,0.001,8,15,1,5,1,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.285051067780873,0.0,0.714948932219127
5,60,0.001,8,15,1,5,1,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.285051067780873,0.0,0.714948932219127
5,50,0.001,6,30,1,5,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.297551789077213,0.0,0.702448210922787
5,60,0.001,6,30,1,5,2,23.219656,120.161758,BP_35,20170402-20170928,CHCH,0.297551789077213,0.0,0.702448210922787
"""


@testset "csv_deser.jl" begin
    # Test CSV deserialization
    best_models = deser_csv(GEMSMagTIP.BestModels, csv_bestmodel)

    # Test that serialization produces expected format
    @test_throws GEMSMagTIP.NotSupported to_csv(best_models)



    # # Stupid Claude tests:
    # Test we get the expected number of models
    @test length(best_models) == 8

    # Test structure of first model
    first_model = best_models[1]
    @test isa(first_model, GEMSMagTIP.BestModels)

    # Test field values of first model
    @test first_model.Mc == 5
    @test first_model.Rc == 50
    @test first_model.NthrRatio ≈ 0.001
    @test first_model.Tthr == 2
    @test first_model.Tobs == 5
    @test first_model.Tpred == 1
    @test first_model.Tlead == 5
    @test first_model.Athr == 2
    @test first_model.Lat ≈ 23.219656
    @test first_model.Lon ≈ 120.161758
    @test first_model.prp == "BP_35"
    @test first_model.stn == "CHCH"
    @test first_model.AlarmedRate ≈ 0.217913204062789
    @test first_model.MissedRate ≈ 0.0
    @test first_model.FittingDegree ≈ 0.782086795937211

    # Test Phase deserialization for date range
    @test first_model.frc.t0 == Date(2017, 4, 2)
    @test first_model.frc.t1 == Date(2017, 9, 28)

    # Test that models with same parameters but different Rc are distinct
    @test best_models[1] != best_models[2]
    @test best_models[1].Rc == 50
    @test best_models[2].Rc == 60

    # Test that same station/parameters with different Tlead are distinct
    @test best_models[1] != best_models[3]
    @test best_models[1].Tlead == 5
    @test best_models[3].Tlead == 15


end
