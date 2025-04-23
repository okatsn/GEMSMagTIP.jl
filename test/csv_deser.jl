using Serde
using GEMSMagTIP
using Dates
using CSV, DataFrames
using OkTableTools
using Chain

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


@testset "CSV BestModels" begin
    # Test CSV deserialization via deser_csv (which uses parse_csv internally)
    best_models = Serde.deser_csv(GEMSMagTIP.BestModels, csv_bestmodel)

    # Test that CSV serialization is not supported for BestModels
    @test_throws GEMSMagTIP.NotSupported Serde.to_csv(best_models)
    @test length(best_models) == 8

    # Test individual field values in the first model
    first_model = best_models[1]
    @test isa(first_model, GEMSMagTIP.BestModels)
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

    # Test that the Phase field is correctly parsed from the string "20170402-20170928"
    mktemp() do io, temp_file
        # --- Additional test for file-based CSV reading via core_read ---
        # Write the CSV string to a temporary file.
        write(io, csv_bestmodel)
        core_models = GEMSMagTIP.core_read(Val(GEMSMagTIP.file_bestmodels), temp_file)

        @test core_models[1].frc.t0 == first_model.frc.t0 == Date(2017, 4, 2)
        @test core_models[1].frc.t1 == first_model.frc.t1 == Date(2017, 9, 28)

        # Test distinctness: models with same parameters but different Rc
        @test core_models[2] != best_models[1] != best_models[2]
        @test best_models[1].Rc == 50
        @test core_models[2].Rc == best_models[2].Rc == 60

        # Test distinctness for models with same station/parameters but different Tlead
        @test best_models[1] != best_models[3]
        @test best_models[1].Tlead == 5
        @test core_models[3].Tlead == best_models[3].Tlead == 15

        @test length(core_models) == 8
        @test core_models[1] == first_model
    end
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

@testset "CSV FittingDegree" begin
    # Test CSV deserialization
    fitting_degrees = deser_csv(GEMSMagTIP.FittingDegree, csv_fittingdegree)

    # Test that serialization produces expected format
    @test_throws GEMSMagTIP.NotSupported to_csv(fitting_degrees)

    mktempdir() do path
        file = joinpath(path, "fittingDegree.csv")
        write(file, csv_fittingdegree)
        df = GEMSMagTIP.read_data(file, DataFrame)
        rows = [row for row in eachrow(df)]
        row1 = rows[1]
        row10 = rows[10]
        row11 = rows[11]
        row2 = rows[2]

        # Test we get the expected number of records
        @test nrow(df) == length(fitting_degrees) == 11

        # Test structure of first record
        first_record = fitting_degrees[1]
        @test isa(first_record, GEMSMagTIP.FittingDegree)

        # Test field values of first record
        @test row1.areaTIP == first_record.areaTIP ≈ 146.058765432099
        @test row1.nEQK == first_record.nEQK == 2
        @test row1.prp == first_record.prp == "BP_35"
        @test row1.NEQ_min == first_record.NEQ_min == 1
        @test row1.NEQ_max == first_record.NEQ_max == 4
        @test row1.AlarmedRate == first_record.AlarmedRate ≈ 0.331099608140137
        @test row1.MissedRate == first_record.MissedRate ≈ 0.5
        @test row1.FittingDegree == first_record.FittingDegree ≈ 0.16890039185986305

        # Test Phase deserialization for date range
        @test row1.frc.t0 == first_record.frc.t0 == Date(2017, 4, 2)
        @test row1.frc.t1 == first_record.frc.t1 == Date(2017, 9, 28)

        # Test some specific cases
        # Test record with highest nEQK
        max_eqk_record = fitting_degrees[10]  # The one with 4 EQKs

        @test row10.nEQK == max_eqk_record.nEQK == 4
        @test row10.MissedRate == max_eqk_record.MissedRate ≈ 0.75

        # Test record with lowest nEQK
        min_eqk_record = fitting_degrees[11]  # The one with 1 EQK
        @test row11.nEQK == min_eqk_record.nEQK == 1
        @test row11.MissedRate == min_eqk_record.MissedRate ≈ 1.0

        # Test that records with same parameters but different areaTIP are distinct
        @test fitting_degrees[1] != fitting_degrees[2]
        @test row1.areaTIP == fitting_degrees[1].areaTIP ≈ 146.058765432099
        @test row2.areaTIP == fitting_degrees[2].areaTIP ≈ 151.453333333333

    end
end


csv_statind = """
DateTime,stn,prp,var_S_NS,var_S_EW,var_K_NS,var_K_EW,var_SE_NS,var_SE_EW,var_S_x,var_S_y,var_S_z,var_K_x,var_K_y,var_K_z,var_SE_x,var_SE_y,var_SE_z,var_K,var_S,var_SE,var_FI_NS,var_FI_EW,var_FI_x,var_FI_y,var_FI_z
01-Jan-2014,CHCH,BP_35,-0.0927770121892476,-1.31874297807944,4.37903614786034,13.064348617259,-5.5803137772684,-6.31776573453275,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1.5110123797811e6, 8.15556990175128e6, NaN, NaN, NaN
02-Jan-2014,CHCH,BP_35,0.187720693444812,-0.264511576155514,6.54105004873713,4.79664867202574,-5.81313692082173,-6.09675918233375,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2.29495879724223e6, 3.88369819559427e6, NaN, NaN, NaN
03-Jan-2014,CHCH,BP_35,-0.00844443916921936,-0.127375504393208,4.89829001181269,5.34293498626927,-5.71858373287784,-6.07397682964251,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1.91235767696348e6, 3.68457994685619e6, NaN, NaN, NaN
04-Jan-2014,CHCH,BP_35,-0.0414044203162809,-0.148199925708041,7.40946320265025,6.63452522842359,-5.91663963477171,-6.41910093510377,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,2.94815607273639e6, 8.14991910566193e6, NaN, NaN, NaN
05-Jan-2014,CHCH,BP_35,1.60762564931821,-1.02326158017884,29.4399895410091,12.5142689105151,-6.02998555779309,-6.45526073796715,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,3.7834217629928e6, 8.45119943032876e6, NaN, NaN, NaN
06-Jan-2014,CHCH,BP_35,-0.296415379821155,-0.120612223140257,6.72995703810994,10.9870898235287,-6.18037210771856,-6.32856717462572,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,4.8204504377151e6, 6.71371396560895e6, NaN, NaN, NaN
07-Jan-2014,CHCH,BP_35,0.499346790569236,-0.463512131235742,10.7822824059376,5.68181864971525,-6.10632444729206,-6.31376091445911,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,4.67257517542692e6, 6.42771267385233e6, NaN, NaN, NaN
08-Jan-2014,CHCH,BP_35,0.817531166038516,2.12452639723315,13.8178460799605,26.5446773517998,-5.84701426294977,-6.27127152807284,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,3.21677955144294e6, 7.36021153865845e6, NaN, NaN, NaN
09-Jan-2014,CHCH,BP_35,0.332470478056347,0.0572627911405571,11.5359107276184,5.98523837622511,-5.97831720439458,-6.39653142991098,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,3.53130136567404e6, 7.47895228268932e6, NaN, NaN, NaN
10-Jan-2014,CHCH,BP_35,1.22352198314208,0.734538227098344,16.7991258631776,12.9480994103386,-5.92978665351276,-6.1574046117693,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,3.43397281449696e6, 4.70805029398497e6, NaN, NaN, NaN
11-Jan-2014,CHCH,BP_35,0.850146763991446,-0.433661274397261,24.7140843542151,5.55554749239246,-6.25214963464028,-6.41114515197611,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,7.07274267913311e6, 7.00678578581191e6, NaN, NaN, NaN
12-Jan-2014,CHCH,BP_35,1.07829085762279,-0.154353918670885,14.4540662741981,4.66344636793813,-5.85276811950442,-6.27160200259897,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,3.55190160670375e6, 5.4780043040648e6, NaN, NaN, NaN
"""

@testset "CSV Specialized case: Statind" begin
    mktempdir() do path
        file = joinpath(path, "StatInd.csv")
        write(file, csv_statind)

        # df0 is the raw CSV read directly into a DataFrame.
        df0 = CSV.read(file, DataFrame)
        # df is the processed DataFrame from GEMSMagTIP.read_data
        df = GEMSMagTIP.read_data(file, DataFrame)

        # Check that df0 has the original CSV structure.
        @test nrow(df0) == 12
        @test ncol(df0) == 26

        # Check that the processed DataFrame has the expected columns.
        @test nrow(df) == 12
        @test ncol(df) == 4
        @test Set(names(df)) == Set(["DateTime", "stn", "prp", "var"])

        # Test content of the first row.
        row1 = first(eachrow(df))

        # Test that all var_* columns are consolidated into the var NamedTuple
        @test !any(contains.(names(df), "var_"))
        @test isa(row1.var, NamedTuple)

        # Test specific values in first row
        @test row1.DateTime == Date(2014, 1, 1)
        @test row1.stn == "CHCH"
        @test row1.prp == "BP_35"
        @test isa(row1.var, NamedTuple)
        @test haskey(row1.var, :var_S_NS)
        @test row1.var.var_S_NS ≈ -0.0927770121892476
        @test row1.var.var_S_NS ≈ -0.0927770121892476
        @test row1.var.var_S_EW ≈ -1.31874297807944
        @test row1.var.var_K_NS ≈ 4.37903614786034
        @test row1.var.var_K_EW ≈ 13.064348617259
        @test row1.var.var_SE_NS ≈ -5.5803137772684
        @test row1.var.var_SE_EW ≈ -6.31776573453275

        # Test content of an additional row (e.g., the 5th row).
        row5 = df[5, :]
        @test row5.DateTime == Date(2014, 1, 5)
        @test row5.stn == "CHCH"
        @test row5.prp == "BP_35"
        @test isa(row5.var, NamedTuple)
        @test haskey(row5.var, :var_S_NS)
        @test row5.var.var_S_NS ≈ 1.60762564931821


        # Test specific values in last row
        row12 = last(eachrow(df))
        @test row12.DateTime == Date(2014, 1, 12)
        @test row12.var.var_S_NS ≈ 1.07829085762279
        @test row12.var.var_K_EW ≈ 4.66344636793813

        # Test that NaN values are preserved in the var NamedTuple
        @test all(isnan.(values(row1.var)[12:15]))  # var_S_x through var_SE

        # Test conversion to Vector{StatInd}
        stat_vec = GEMSMagTIP.read_data(file, Vector{GEMSMagTIP.StatInd})
        @test length(stat_vec) == 12
        @test isa(stat_vec[1], GEMSMagTIP.StatInd)

        # Test first StatInd object
        first_stat = stat_vec[1]
        @test first_stat.DateTime == Date(2014, 1, 1)
        @test first_stat.stn == "CHCH"
        @test first_stat.prp == "BP_35"
        @test first_stat.var.var_S_NS ≈ -0.0927770121892476

        # Test whether the variable names are standardized

        @test isnan(first_stat.var.var_S_North)
        @test isnan(first_stat.var.var_S_East)
        @test isnan(first_stat.var.var_S_Down)
        @test_throws "type NamedTuple has no field" isnan(first_stat.var.var_S_x)
        @test_throws "type NamedTuple has no field" isnan(first_stat.var.var_S_y)
        @test_throws "type NamedTuple has no field" isnan(first_stat.var.var_S_z)


    end
end

@testset "Test Stat's rename function" begin
    rawcsv = Serde.parse_csv(csv_statind) # named tuples
    df0 = rawcsv |> DataFrame
    _deser_wide(rows) = Serde.to_deser(Vector{GEMSMagTIP.StatInd}, rows)
    df = GEMSMagTIP.process_before_deser(GEMSMagTIP.StatInd, rawcsv) |> _deser_wide |> DataFrame
    # Revert `df`
    dfr = @chain df begin
        transform(:var => AsTable)
        select(Not(:var))
        transform(:DateTime => ByRow(t -> Dates.format(t, GEMSMagTIP.info_date_format)); renamecols=false)
    end
    @test dataframes_equal(
        rename(GEMSMagTIP.standardize_var_suffix, df0; cols=Cols(GEMSMagTIP.expr_matchstatvar)),
        dfr)
end

@testset "CSV Specialized case: Statind_long" begin
    rawcsv = Serde.parse_csv(csv_statind) # named tuples
    statind_long = GEMSMagTIP.process_before_deser(GEMSMagTIP.StatInd_long, rawcsv) |> DataFrame
    statind_long_unstacked = unstack(statind_long, GEMSMagTIP.statind_stack_id, :variable, :value)
    statind = @chain GEMSMagTIP.process_before_deser(GEMSMagTIP.StatInd, rawcsv) begin
        DataFrame
        transform(:var => identity => AsTable)
        rename(x -> replace(x, "var_" => ""), _; cols=Cols(r"\Avar\_"))
        select(Not(:var))
    end

    sort!(statind, [:DateTime, :stn, :prp])
    sort!(statind_long_unstacked, [:DateTime, :stn, :prp])
    @test dataframes_equal(statind, statind_long_unstacked)
end

using OkInformationalAnalysis, Serde
# using GEMSMagTIP, DataFrames

@testset "Test Stat's Configuration interface" begin
    rawcsv = Serde.parse_csv(csv_statind) # named tuples
    df0 = rawcsv |> DataFrame

    @test all(in(Set([
            "var_SE_NS",
            "var_SE_EW",
            "var_SE_x",
            "var_SE_y",
            "var_SE_z",
            "var_SE",
        ])), names(select(df0, GEMSMagTIP.expr_matchse)))

    # `rows` output by `process_before_deser` contains number in type String; `to_deser` convert them to Float64 according to StatInd_long.
    _deser_long(rows) = Serde.to_deser(Vector{GEMSMagTIP.StatInd_long}, rows)
    config = (sep=true, logfi=true)
    pc = GEMSMagTIP.PreprocessConfig(GEMSMagTIP.StatInd_long, config)
    statind_long = GEMSMagTIP.process_before_deser(pc, rawcsv) |> _deser_long |> DataFrame

    # Test whether old variables were no longer available.
    @test all(!in(Set([
            "var_SE_NS",
            "var_SE_EW",
            "var_SE_x",
            "var_SE_y",
            "var_SE_z",
            "var_SE",
            "var_FI_NS",
            "var_FI_EW",
            "var_FI_x",
            "var_FI_y",
            "var_FI_z",
            "var_FI",
        ])), unique(statind_long.variable))

    statind_long0 = GEMSMagTIP.process_before_deser(GEMSMagTIP.StatInd_long, rawcsv) |> _deser_long |> DataFrame
    onlyse0 = filter(:var_type => (t -> t == "SE"), statind_long0)
    onlyse1 = filter(:var_type => (t -> t == "SEP"), statind_long)

    let test_count = 0

        @test nrow(onlyse0) == nrow(onlyse1)
        for (r0, r1) in zip(eachrow(onlyse0), eachrow(onlyse1))
            if !isnan(r1.value)
                @test se2sep(r0.value) ≈ r1.value
                test_count += 1
            end
        end

        @test test_count > 0 # make sure the for-loop tests not zero
    end

    let test_count = 0
        onlyfi0 = filter(:var_type => (t -> t == "FI"), statind_long0)
        onlyfi1 = filter(:var_type => (t -> t == "log₁₀(FI)"), statind_long)

        @test nrow(onlyfi0) > 0
        @test nrow(onlyfi0) == nrow(onlyfi1)
        for (r0, r1) in zip(eachrow(onlyfi0), eachrow(onlyfi1))
            if !isnan(r1.value)
                @test log10(r0.value) ≈ r1.value
                test_count += 1
            end
        end
        @test test_count > 0 # make sure the for-loop tests not zero

    end

end
