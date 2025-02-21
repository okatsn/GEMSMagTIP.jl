module GEMSMagTIP

using Serde, Dates

using StructEquality

# `@struct_hash_equal` allows comparison of Info. See https://juliapackages.com/p/structequality
@struct_hash_equal struct Info
    Identifier::String
    # DataInterval::Vector{Vector{Date}}
    DataInterval::Vector{Date}
    FunctionNames::Vector{String}
    FunctionHandles::Vector{String}
    # TrainingPhase::Vector{Vector{Date}}
    # ForecastingPhase::Vector{Vector{Date}}
end

# KEYNOTEs:
# @ Serde ~/.julia/packages/Serde/ws7xp/src/De/Deser.jl:402
# In debug mode, in `deser(ct, ft, data)`,
# `ct` is `GEMSMagTIP.Info`,
# `ft` is the type of field in `Info` (e.g., `Vector{Dates.Date}`), and
# `data` is the value from `Serde.ParJson.parse_json`
# (e.g., `Any["01-Jan-2014", "25-Jun-2024"]`).
#
# This means the following function should process `v` and the result returned must match the type of `ft`.
function Serde.deser(::Type{Info}, ::Type{Vector{Date}}, v)
    return Dates.Date.(v, "d-u-Y")
end

end
