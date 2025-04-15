abstract type StatisticalIndex <: CSVRow end

"""
```
struct StatInd
    DateTime::Date
    stn::String
    ID::String
    prp::String
    var::NamedTuple
    varQuality::Float64
end
```

`df = GEMSMagTIP.read_data(file, DataFrame)`.

To revert `df` the same columns as the csv `file`:

```
@chain df begin
    transform(:var => AsTable)
    select(Not(:var))
    transform(:DateTime => ByRow(t -> Dates.format(t, GEMSMagTIP.info_date_format)); renamecols=false)
end
```
"""
struct StatInd <: StatisticalIndex
    DateTime::Date
    stn::String
    prp::String
    var::NamedTuple
    varQuality::Float64
end


struct StatInd_long <: StatisticalIndex
    DateTime::Date
    stn::String
    prp::String
    variable::String
    var_type::String
    var_comp::String
    varQuality::Float64
end

"""
Matches "var_SE_EW".
"""
const expr_matchstatvar = r"\Avar\_"

"""
Matches "SE_EW" for "var_SE_EW".
"""
const expr_matchstatvarrest = r"(?<=\Avar\_).*"


const prefix_var = "var"

const standard_code = Dict(
    "" => "Full",
    "EW" => "EW",
    "NS" => "NS",
    "x" => "North",
    "y" => "East",
    "z" => "Down",
)

"""
`standardize_var_suffix` standardize the direction suffix of a variable name.

For example,

```jldoctest
julia> GEMSMagTIP.standardize_var_suffix("S")
"S_Full"

julia> GEMSMagTIP.standardize_var_suffix("S_x")
"S_North"

julia> GEMSMagTIP.standardize_var_suffix("S_y")
"S_East"

julia> GEMSMagTIP.standardize_var_suffix("S_z")
"S_Down"

julia> GEMSMagTIP.standardize_var_suffix("S_EW")
"S_EW"

julia> GEMSMagTIP.standardize_var_suffix("S_NS")
"S_NS"
```

Additional prefix of "$(prefix_var)_" will be preserved:

```jldoctest
julia> GEMSMagTIP.standardize_var_suffix("var_S")
"var_S_Full"

julia> GEMSMagTIP.standardize_var_suffix("var_S_EW")
"var_S_EW"
```
"""
function standardize_var_suffix(s::AbstractString)
    sv = rsplit(s, "_", limit=2)

    if length(sv) == 1 ||
       (first(sv) == prefix_var && length(sv) == 2) # Consider also the case like "var_S"
        push!(sv, "")
    end

    sv[end] = standard_code[last(sv)]
    join(sv, "_")
end

# Specialized data preprocessing.
function process_before_deser(T::Type{StatInd}, stat::CSV.File)
    stat1 = @chain stat begin
        DataFrame
        rename(GEMSMagTIP.standardize_var_suffix, _; cols=Cols(expr_matchstatvar))
        transform(AsTable(expr_matchstatvar) => ByRow(identity) => Symbol(prefix_var))
        select(Not(expr_matchstatvar))
    end
    rows = stat1 |> CSV.rowtable
    return rows
end


"""
For transforming `:variable` to `:var_type` and `:var_comp`.

# Example

`transform(:variable => ByRow(v -> varstr2nt) => AsTable)`
"""
function varstr2nt(v)
    sv = rsplit(v, "_", limit=2)
    NamedTuple{(:var_type, :var_comp)}(sv)
end

function process_before_deser(T::Type{StatInd_long}, stat::CSV.File)
    stat1 = @chain stat begin
        DataFrame
        rename(GEMSMagTIP.standardize_var_suffix, _; cols=Cols(expr_matchstatvar))
        # stack on `var_...`
        stack(Cols(expr_matchstatvar), [:DateTime, :stn, :prp])
        # keep the rest (`...`) for `var_...`
        transform(:variable => ByRow(v -> match(expr_matchstatvarrest, v).match); renamecols=false)
        transform(:variable => ByRow(varstr2nt) => AsTable)
    end
    rows = stat1 |> CSV.rowtable
    return rows
end

function Serde.deser(::Type{<:StatisticalIndex}, ::Type{Dates.Date}, data)
    return Dates.Date(data, info_date_format)
end
# KEYNOTE:
# Conventionally, each field in `StatInd` fields should match the corresponding column in the csv to be imported, in a one-by-one manner.
# In this case, one should define, for example `Serde.deser(::Type{::StatInd}, ::Type{Date}, data)`, that manipulate the `data` of type `Date` matched by the field name in struct found in the column of the CSV. Such as the column "DateTime" in CSV that was inferred from `StatInd.DateTime::Date` will going to be applied.
#
# However, in our case, the `StatInd.csv` data does not have a fixed columns, where values of variables are stores as `var_...` in columns, and the number of columns might changes.
# In this case, we have no mean for `Serde.deser_csv` to work, because `StatInd.var::NamedTuple` is a summarized results from multiple columns rather than a specific column in CSV.
# Since `Serde.deser_csv` calls `to_deser`, we call `to_deser` directly instead in `_vec_deser`.
