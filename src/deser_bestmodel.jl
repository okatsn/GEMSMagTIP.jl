struct BestModels
    Mc::Int64
    Rc::Int64
    NthrRatio::Float64
    Tthr::Int64
    Tobs::Int64
    Tpred::Int64
    Tlead::Int64
    Athr::Int64
    Lat::Float64
    Lon::Float64
    prp::String
    frc::Phase
    stn::String
    AlarmedRate::Float64
    MissedRate::Float64
    FittingDegree::Float64
end

const frc_date_format = "yyyymmdd"

function Serde.deser(::Type{BestModels}, ::Type{Phase}, data)
    v = split(data, "-")
    return Phase(Dates.Date.(v, frc_date_format))
    # `v` is a vector of two date strings.
end



# CHECKPOINT: Since `Serde.SerCsv.` do not have `ser_type` or `ser_value`, the following application for serialization to CSV do no effect.
# function Serde.ser_type(::Type{BestModels}, var::Phase)
#     return Dates.format(var.t0, frc_date_format) * "-" * Dates.format(var.t1, frc_date_format)
# end
# function Serde.ser_value(::Type{BestModels}, ::Val{:frc}, var::Phase)
#     return Dates.format(var.t0, frc_date_format) * "-" * Dates.format(var.t1, frc_date_format)
# end

function Base.showerror(io::IO, e::NotSupported)
    print(io, "NotSupported: $(e.message)")
end

function Serde.to_csv(::Vector{BestModels})
    throw(NotSupported("CSV serialization"))
end
