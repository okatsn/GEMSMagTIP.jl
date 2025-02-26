core_read(::Val{file_fittingdegree}, path) = _vec_deser(FittingDegree, path)
core_read(::Val{file_bestmodels}, path) = _vec_deser(BestModels, path)


function _vec_deser(T, path)
    data0 = CSV.File(path)
    rows = data0 |> CSV.rowtable
    # # KEYNOTE: The following processing works, but superfluous because the final destination of `deser_csv` is `to_deser`, which already accepts rows.
    # csv0 = rows |> to_csv # Parse to a string of csv data
    # output = Serde.deser_csv(GEMSMagTIP.FittingDegree, csv0)

    # # KEYNOTEs:
    # - In #file:DeCsv.jl, `deser_csv` calls `parse_csv`, which parse the csv string to NamedTuples, and send the NamedTuples to `to_deser(Vector{T}, parse_csv(x))`.
    # - In #file:ParCsv.jl , you can see `parse_csv` basically calls `CSV.rowtable` and returns a vector of `NamedTuple`s.
    output = Serde.to_deser(Vector{T}, rows)
    # Output a vector of FittingDegree or etc.
end
