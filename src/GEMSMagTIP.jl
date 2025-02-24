module GEMSMagTIP

using Serde, Dates

using StructEquality



struct Phase
    t0::Date
    t1::Date
end

Phase(v::Vector) = Phase(v...)

function Dates.format(p::Phase)
    return [
        Dates.format(p.t0, info_date_format),
        Dates.format(p.t1, info_date_format)
    ]
end

const info_date_format = "dd-u-Y"





# `@struct_hash_equal` allows comparison of Info. See https://juliapackages.com/p/structequality
@struct_hash_equal struct Info
    Identifier::String
    DataInterval::Phase
    FunctionNames::Vector{String}
    FunctionHandles::Vector{String}
    TrainingPhase::Vector{Phase}
    ForecastingPhase::Vector{Phase}
end


function Info(id, di::Vector{Vector{String}}, fn, fh, tp::Vector{Vector{String}}, fp::Vector{Vector{String}})
    Info(
        id,
        Phase(Dates.Date.(only(di), info_date_format)),
        fn,
        fh,
        Phase.([Dates.Date.(v, info_date_format) for v in tp]),
        Phase.([Dates.Date.(v, info_date_format) for v in fp]),
    )
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
function Serde.deser(::Type{Info}, ::Type{Vector{Phase}}, data)
    return [Phase(Dates.Date.(v, info_date_format)) for v in data]
    # `v` is a vector of two date strings.
end

# JSON serialization
function Serde.SerJson.ser_type(::Type{Info}, var::Vector{Phase})
    return [Dates.format(p, info_date_format) for p in var]
    # `p` is a `Phase`
end




end
