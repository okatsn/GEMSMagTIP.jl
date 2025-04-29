
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

"""
`read_data(path, DataFrame)` dispatch deserialization by file name. For example, if `basename(path)` is `$file_statind`, it returns the `DataFrame` with each row being `$(split(string(file_statind), ".")[1])`.

In this case, it is equivalent as calling `read_data($(split(string(file_statind), ".")[1]), path, DataFrame)`.

"""
read_data(path, sink) = core_read(path) |> sink

"""
`read_data(T::Union{Type{<:CSVRow},PreprocessConfig}, path, sink)` deserialize data to type `T` for arbitrary file name, and finally returned as data of type `sink`.

# Example

```julia
using GEMSMagTIP
GEMSMagTIP.read_data(StatInd, "data.csv", DataFrame)
```
"""
read_data(T, path, sink) = core_read(T, path) |> sink
core_read(T, path) = _vec_deser(T, path)

# # SECTION: Establish link between `Val` of file and `Type` of data struct.

# Fall back to general cases.
core_read(::Val{file_fittingdegree}, path) = _vec_deser(FittingDegree, path)
core_read(::Val{file_bestmodels}, path) = _vec_deser(BestModels, path)

# Fall back to specialized cases. (See deser_statind.jl)
core_read(::Val{file_statind}, path) = _vec_deser(StatInd, path)


# General case (no extra processing)
function _vec_deser(T, path)
    data0 = CSV.File(path)
    rows = process_before_deser(T, data0)
    # # KEYNOTE: The following processing works, but superfluous because the final destination of `deser_csv` is `to_deser`, which already accepts rows.
    # csv0 = rows |> to_csv # Parse to a string of csv data
    # output = Serde.deser_csv(GEMSMagTIP.FittingDegree, csv0)

    # # KEYNOTEs:
    # - In #file:DeCsv.jl, `deser_csv` calls `parse_csv`, which parse the csv string to NamedTuples, and send the NamedTuples to `to_deser(Vector{T}, parse_csv(x))`.
    # - In #file:ParCsv.jl , you can see `parse_csv` basically calls `CSV.rowtable` and returns a vector of `NamedTuple`s.
    output = Serde.to_deser(_create_vector_type(T), rows)
    # Output a vector of FittingDegree or etc.
end

_create_vector_type(T::DataType) = Vector{T}
_create_vector_type(pc::PreprocessConfig) = Vector{pc.datatype}


"""
Internally called `_vec_deser`, and returns `CSV.rowtable` whose columns match fields in `T`.
"""
function process_before_deser(T::Type{<:CSVRow}, f)
    rows = f |> CSV.rowtable
    return rows
end # for any other types.

function process_before_deser(pc::PreprocessConfig, f)
    process_before_deser(pc.datatype, f; pc.config...)
end
