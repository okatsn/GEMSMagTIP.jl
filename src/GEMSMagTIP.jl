module GEMSMagTIP

using Serde, Dates

using StructEquality

# `@struct_hash_equal` allows comparison of Info. See https://juliapackages.com/p/structequality
@struct_hash_equal struct Info
    Identifier::String
    DataInterval::Vector{Vector{Date}}
    FunctionNames::Vector{String}
    FunctionHandles::Vector{String}
    TrainingPhase::Vector{Vector{Date}}
    ForecastingPhase::Vector{Vector{Date}}
end

# KEYNOTEs:
# @ Serde ~/.julia/packages/Serde/ws7xp/src/De/Deser.jl:402
# In debug mode, in `deser(ct, ft, data)`,
# `ct` is `GEMSMagTIP.Info`,
# `ft` is the type of field in `Info` (e.g., `Vector{Dates.Date}`), and
# `data` is the value from `Serde.ParJson.parse_json`
# (e.g., `Any["01-Jan-2014", "25-Jun-2024"]`).
#
# In summary, `deser` aims for arbitrary deserialization of `data` via
# the following custom function that should process `data` and the result returned must match the type of `ft`.
# The rule means, if a key (e.g., `DataInterval`) in JSON is iterated, the type corresponding the same field name of `Info` (e.g., `Info.DataInterval::Vector{Vector{Date}}`) infers the function to be dispatched to process the data.
function Serde.deser(::Type{Info}, ::Type{Vector{Vector{Date}}}, data)
    return [Dates.Date.(v, "dd-u-Y") for v in data]
end

# JSON serialization
function Serde.SerJson.ser_type(::Type{Info}, var::Vector{Vector{Date}})
    return [Dates.format.(v, "dd-u-Y") for v in var]
end

end
