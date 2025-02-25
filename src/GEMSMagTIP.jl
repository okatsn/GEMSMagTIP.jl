module GEMSMagTIP

using Serde, Dates

using StructEquality



struct Phase
    t0::Date
    t1::Date
end

# For v a vector of `Date`
Phase(v::Vector) = Phase(v...)

const frc_date_format = "yyyymmdd"

function Phase(data::String)
    v = split(data, "-")
    return Phase(Dates.Date.(v, frc_date_format))
end

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

function Base.showerror(io::IO, e::NotSupported)
    print(io, "NotSupported: $(e.message)")
end


include("deser_info.jl")

include("deser_bestmodel.jl")

include("deser_fittingdegree.jl")

# # The followings are too specific,
# Serde.deser(::Type{FittingDegree}, ::Type{Phase}, data::String) = Phase(data)
# Serde.deser(::Type{BestModels}, ::Type{Phase}, data::String) = Phase(data) # `v` is a vector of two date strings.
# # and can be replaced by:
function Serde.deser(::Type{GEMSMagTIP.Phase}, data::AbstractString)
    return GEMSMagTIP.Phase(data)
end


# # Extend CSV.read and JSON.parse

using CSV

include("const_filename.jl")
include("core_read.jl")
include("csv_read.jl")


end
