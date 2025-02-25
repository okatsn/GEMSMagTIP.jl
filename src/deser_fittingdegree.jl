struct FittingDegree
    areaTIP::Float64
    nEQK::Int64
    prp::String
    frc::Phase
    NEQ_min::Int64
    NEQ_max::Int64
    AlarmedRate::Float64
    MissedRate::Float64
    FittingDegree::Float64
end



function Serde.to_csv(::Vector{FittingDegree})
    throw(NotSupported("CSV serialization"))
end
