module GEMSMagTIP

using Serde, Dates

using StructEquality

using Chain

struct Phase
    t0::Date
    t1::Date
end

# For v a vector of `Date`
Phase(v::Vector) = Phase(v...)

const frc_date_format = "yyyymmdd"

# KEYNOTE: `data` cannot be to specific (e.g., `data::String`), otherwise, you will encounter such as `MethodError: no method matching GEMSMagTIP.Phase(::String31)`.
function Phase(data::AbstractString)
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


# # Deserialization for specific format

const info_date_format = "dd-u-Y"
include("const_filename.jl")


include("deser_info.jl")


abstract type CSVRow end

"""
Configuration for `process_before_deser`.
"""
struct PreprocessConfig
    datatype::Type{CSVRow}
    config::NamedTuple
end


include("deser_bestmodel.jl")

include("deser_fittingdegree.jl")

using DataFrames, CSV
using OkInformationalAnalysis
include("deser_statind.jl")


# # General deserialization codes


# # The followings are too specific,
# Serde.deser(::Type{FittingDegree}, ::Type{Phase}, data::String) = Phase(data)
# Serde.deser(::Type{BestModels}, ::Type{Phase}, data::String) = Phase(data) # `v` is a vector of two date strings.
# # and can be replaced by:
function Serde.deser(::Type{GEMSMagTIP.Phase}, data::AbstractString)
    # This function means that, for `T` (e.g., `FittingDegree`) in
    # `Serde.deser_csv(::Type{T}, csv_bestmodel)`,
    # for the field(s) of `T` being `Phase` (e.g., `frc::Phase`),
    # the data in the column of name the same as the field name (e.g., `frc`),
    # will be processed here.
    return GEMSMagTIP.Phase(data)
end


# # Extend CSV.read and JSON.parse

using CSV

include("core_read.jl")


end
