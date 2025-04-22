abstract type StatisticalIndex <: CSVRow end

"""
```
struct StatInd
    DateTime::Date
    stn::String
    prp::String
    var::NamedTuple
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
end


struct StatInd_long <: StatisticalIndex
    DateTime::Date
    stn::String
    prp::String
    variable::String
    value::Float64
    var_type::String
    var_comp::String
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
       (first(sv) == prefix_var && length(sv) == 2) # Consider the case of no suffix, such as "var_S"
        push!(sv, "") # the empty string will be replaced by "full". See the dictionary `standard_code`.
    end

    # Replace the last string segment according to the dictionary.
    sv[end] = standard_code[last(sv)]
    join(sv, "_")
end

# Specialized data preprocessing.
function process_before_deser(::Type{StatInd}, stat)
    stat1 = @chain stat begin
        DataFrame
        rename(standardize_var_suffix, _; cols=Cols(expr_matchstatvar))
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

const statind_stack_id = [:DateTime, :stn, :prp]

"""
A function that generates `Regex` for matching variable name with `$prefix_var` prefix but without suffix.

# Example

```jldoctest
julia> match(GEMSMagTIP.tomatchvar("FI"), "var_FI_EW").match
"var_FI"

julia> match(GEMSMagTIP.tomatchvar("FI"), "var_FI").match
"var_FI"

julia> match(GEMSMagTIP.tomatchvar("FI"), "var_FIX") # should return nothing


julia> match(GEMSMagTIP.tomatchvar("FI"), "Nevar_FI") # should return nothing


```

"""
tomatchvar(x) = Regex("(?<=\\A)$(prefix_var)_$x(?=(\\Z|\\_))")

const expr_matchvarse = tomatchvar("SE")
const expr_matchvarfim = tomatchvar("FI")

"""
A function that generates `Regex` for matching variable name without `$prefix_var` prefix and suffix.

# Example

```jldoctest
julia> match(GEMSMagTIP.tomatchvarcore("SE"), "var_SE_EW").match
"SE"

julia> match(GEMSMagTIP.tomatchvarcore("SE"), "var_SE").match
"SE"

julia> match(GEMSMagTIP.tomatchvarcore("SE"), "var_SEX")


julia> match(GEMSMagTIP.tomatchvarcore("SE"), "var_LOSE")


```
"""
tomatchvarcore(x) = Regex("(?<=\\A$(prefix_var)\\_)$x(?=\\Z|\\_)")


const expr_matchse = tomatchvarcore("SE")

function strse2sep(s)
    parse(Float64, s) |> se2sep
end

function convertsep(df0)
    @chain df0 begin
        # transform(Cols(expr_matchvarse) .=> ByRow(strse2sep) .=> (s -> replace(s,)))
        # CHECKPOINT: create and test expr_matchse and expr_matchfim  that matches "SE" and "FIM" in order to replace them by SEP (simple replace) and log10(FIM) (replace with @s_str)
        select(expr_matchvarse)
    end
end

function process_before_deser(::Type{StatInd_long}, stat; sep=false, log10fim=false)
    stat1 = @chain stat begin
        DataFrame
        rename(standardize_var_suffix, _; cols=Cols(expr_matchstatvar))
        # stack on `var_...`
        stack(Cols(expr_matchstatvar), statind_stack_id)
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
# In this case, we have no mean for `Serde.deser_csv` to work, because `StatInd.var::NamedTuple` is a summarized result from multiple columns rather than a specific column in CSV.
# Since `Serde.deser_csv` calls `to_deser`, we call `to_deser` directly instead in `_vec_deser`, where `process_before_deser` is the function for split-apply-combine raw csv table to fit in `CSVRow` (e.g., `StatInd_long` and `StatInd`).
