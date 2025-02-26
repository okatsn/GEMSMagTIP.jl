"""
`core_read(path)` attempts to infer `T` for `Serde.to_deser(Vector{T}, ...)` for CSV deserialization based on
the file name in `path`. See `GEMSMagTIP.file_` + [tab] for the supported file names.

This means `core_read` is designed to be dispatched over the `Val` of specific file name (e.g., `file_fitting degree`) that is associated to a specific concrete `struct` (e.g., `FittingDegree`), rather than dispatched by a concrete `struct`.
"""
function core_read end

function core_read(path)
    fname = basename(path)
    core_read(fname, path)
end
core_read(fname::String, path) = core_read(Symbol(fname), path)
core_read(fname::Symbol, path) = core_read(Val(fname), path) # then dispatch by Val(fname) to functions in other src file.


read_data(path, sink) = core_read(path) |> sink
