using Serde
using GEMSMagTIP
using Dates
using JSON

json_data1 = """
{
    "TrainingPhase": [
        [
            "01-Apr-2014",
            "01-Apr-2017"
        ],
        [
            "01-Oct-2014",
            "01-Oct-2017"
        ],
        [
            "01-Apr-2015",
            "01-Apr-2018"
        ]
    ],
    "Identifier": "JF5lTN",
    "FunctionNames": [
        "S",
        "K"
    ],
    "FunctionHandles": [
        "skewness",
        "kurtosis"
    ],
    "ForecastingPhase": [
        [
            "02-Apr-2017",
            "28-Sep-2017"
        ],
        [
            "02-Oct-2017",
            "30-Mar-2018"
        ],
        [
            "02-Apr-2018",
            "28-Sep-2018"
        ]
    ],
    "DataInterval": [
        [
            "01-Jan-2014",
            "25-Jun-2024"
        ]
    ]
}
"""

data1 = JSON.parse(json_data1)

info1 = GEMSMagTIP.Info(
    "JF5lTN",  # Identifier
    # DataInterval
    [["01-Jan-2014", "25-Jun-2024"]],
    # FunctionNames
    ["S", "K"],
    # FunctionHandles
    ["skewness", "kurtosis"],
    # TrainingPhase
    [
        ["01-Apr-2014", "01-Apr-2017"],
        ["01-Oct-2014", "01-Oct-2017"],
        ["01-Apr-2015", "01-Apr-2018"]
    ],
    # ForecastingPhase
    [
        ["02-Apr-2017", "28-Sep-2017"],
        ["02-Oct-2017", "30-Mar-2018"],
        ["02-Apr-2018", "28-Sep-2018"]
    ]
)

info_contentchanged = GEMSMagTIP.Info(
    "JF5lTN",  # Identifier
    # DataInterval
    [Dates.Date.(["01-Jan-2014", "25-Jun-2024"], "d-u-Y")],
    # FunctionNames
    ["S", "K"],
    # FunctionHandles
    ["skewnessX", "kurtosis"],
    # TrainingPhase
    [
        Dates.Date.(["01-Apr-2014", "01-Apr-2017"], "d-u-Y"),
        Dates.Date.(["01-Oct-2014", "01-Oct-2017"], "d-u-Y"),
        Dates.Date.(["01-Apr-2015", "01-Apr-2018"], "d-u-Y")
    ],
    # ForecastingPhase
    [
        Dates.Date.(["02-Apr-2017", "28-Sep-2017"], "d-u-Y"),
        Dates.Date.(["02-Oct-2017", "30-Mar-2018"], "d-u-Y"),
        Dates.Date.(["02-Apr-2018", "28-Sep-2018"], "d-u-Y")
    ]
)


@testset "json_deser.jl" begin

    # Test that deser_json and Serde.deser produce equivalent results when deserializing JSON
    @test deser_json(GEMSMagTIP.Info, json_data1) == Serde.deser(GEMSMagTIP.Info, data1)

    # The deserialized data in type `Info` should be identical to `Info` of exactly the same content.
    @test deser_json(GEMSMagTIP.Info, json_data1) == info1
    @test Serde.deser(GEMSMagTIP.Info, data1) == info1

    # The result from serializing the data of type `Info` should be identical to the original data (compared in the type of `Dict`).
    @test JSON.parse(to_json(info1)) == data1

    # Test that two Info structs with different content are not equal
    # (info_contentchanged has "skewnessX" instead of "skewness")
    # This test essentially test the `StructEquality` of `Info`.
    @test info1 != info_contentchanged
end
