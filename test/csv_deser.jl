using Serde
using GEMSMagTIP
using Dates

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


csv_fittingdegree = """
areaTIP,nEQK,prp,frc,NEQ_min,NEQ_max,AlarmedRate,MissedRate,FittingDegree
146.058765432099,2,BP_35,20170402-20170928,1,4,0.331099608140137,0.5,0.16890039185986305
151.453333333333,3,BP_35,20170402-20170928,1,4,0.325472051856417,1.0,-0.3254720518564169
159.006913580247,3,BP_35,20170402-20170928,1,4,0.355595998621071,1.0,-0.35559599862107105
152.356543209876,3,BP_35,20170402-20170928,1,4,0.396383402156087,1.0,-0.39638340215608703
157.493827160494,2,BP_35,20170402-20170928,1,4,0.396917770635729,1.0,-0.396917770635729
153.098765432099,3,BP_35,20170402-20170928,1,4,0.418104991532941,1.0,-0.418104991532941
148.845432098765,2,BP_35,20170402-20170928,1,4,0.41917043780606,1.0,-0.41917043780606
159.763456790123,3,BP_35,20170402-20170928,1,4,0.381347733222882,1.0,-0.38134773322288207
154.374320987654,2,BP_35,20170402-20170928,1,4,0.408313286928038,1.0,-0.4083132869280379
155.745679012346,4,BP_35,20170402-20170928,1,4,0.383746849089209,0.75,-0.13374684908920897
148.375308641975,1,BP_35,20170402-20170928,1,4,0.412793716301671,1.0,-0.41279371630167105
"""

@testset "csv_deser.jl" begin
    # Test CSV deserialization
    fitting_degrees = deser_csv(GEMSMagTIP.FittingDegree, csv_fittingdegree)

    # Test that serialization produces expected format
    @test_throws GEMSMagTIP.NotSupported to_csv(fitting_degrees)

    # Test we get the expected number of records
    @test length(fitting_degrees) == 11

    # Test structure of first record
    first_record = fitting_degrees[1]
    @test isa(first_record, GEMSMagTIP.FittingDegree)

    # Test field values of first record
    @test first_record.areaTIP ≈ 146.058765432099
    @test first_record.nEQK == 2
    @test first_record.prp == "BP_35"
    @test first_record.NEQ_min == 1
    @test first_record.NEQ_max == 4
    @test first_record.AlarmedRate ≈ 0.331099608140137
    @test first_record.MissedRate ≈ 0.5
    @test first_record.FittingDegree ≈ 0.16890039185986305

    # Test Phase deserialization for date range
    @test first_record.frc.t0 == Date(2017, 4, 2)
    @test first_record.frc.t1 == Date(2017, 9, 28)

    # Test some specific cases
    # Test record with highest nEQK
    max_eqk_record = fitting_degrees[10]  # The one with 4 EQKs
    @test max_eqk_record.nEQK == 4
    @test max_eqk_record.MissedRate ≈ 0.75

    # Test record with lowest nEQK
    min_eqk_record = fitting_degrees[11]  # The one with 1 EQK
    @test min_eqk_record.nEQK == 1
    @test min_eqk_record.MissedRate ≈ 1.0

    # Test that records with same parameters but different areaTIP are distinct
    @test fitting_degrees[1] != fitting_degrees[2]
    @test fitting_degrees[1].areaTIP ≈ 146.058765432099
    @test fitting_degrees[2].areaTIP ≈ 151.453333333333
end
