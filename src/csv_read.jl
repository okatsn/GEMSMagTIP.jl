function core_read(::Val{file_fittingdegree}, path)
    # # CHECKPOINT: The following processing works, but superfluous because the final destination of `deser_csv` is `to_deser`, which already accepts rows.
    data0 = CSV.File(path)
    rows = data0 |> CSV.rowtable
    # Parse to a string of csv data
    csv0 = rows |> to_csv
    # `deser_csv` calls `parse_csv`, which parse the csv string to NamedTuples, and send the NamedTuples to `to_deser`.
    output = Serde.deser_csv(GEMSMagTIP.FittingDegree, csv0)

    # Output a vector of FittingDegree
    return output
end
