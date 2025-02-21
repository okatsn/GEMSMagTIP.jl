using Serde
using GEMSMagTIP
using Dates

json_data1 = """
{
    "Identifier": "JF5lTN",

    "FunctionNames": [

        "S",

        "K"

    ],

    "FunctionHandles": [

        "skewness",

        "kurtosis"

    ],

    "DataInterval": [

            "01-Jan-2014",

            "25-Jun-2024"

    ]

}
"""

data1 = Dict(
    "Identifier" => "JF5lTN", "FunctionNames" => ["S", "K"], "FunctionHandles" => ["skewness", "kurtosis"], "DataInterval" => ["01-Jan-2014", "25-Jun-2024"])

info1 = GEMSMagTIP.Info(
    "JF5lTN",
    Dates.Date.(["01-Jan-2014", "25-Jun-2024"], "d-u-Y"),
    ["S", "K"],
    ["skewness", "kurtosis"],
)
info2 = GEMSMagTIP.Info(
    "JF5lTN",
    Dates.Date.(["01-Jan-2014", "25-Jun-2024"], "d-u-Y"),
    ["S", "K"],
    ["skewnessx", "kurtosis"],
)


@testset "json_deser.jl" begin

    @test deser_json(GEMSMagTIP.Info, json_data1) == Serde.deser(GEMSMagTIP.Info, data1)
    @test deser_json(GEMSMagTIP.Info, json_data1) == info1
    @test Serde.deser(GEMSMagTIP.Info, data1) == info1
    @test info1 != info2
end
