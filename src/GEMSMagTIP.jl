module GEMSMagTIP

using Serde, Dates

using StructEquality



struct Phase
    t0::Date
    t1::Date
end

Phase(v::Vector) = Phase(v...)

function Dates.format(p::Phase, fmt)
    return [
        Dates.format(p.t0, fmt),
        Dates.format(p.t1, fmt)
    ]
end


struct NotSupported <: Exception
    feature::String
    message::String
end


"""
How to use: `throw(NotSupported("CSV serialization"))`.
How to test: `@test_throws GEMSMagTIP.NotSupported ...`
"""
NotSupported(feature::String) = NotSupported(feature, "Feature '$feature' is not supported yet.")

include("deser_info.jl")

include("deser_bestmodel.jl")


end
