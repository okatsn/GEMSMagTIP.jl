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
struct StatInd
    DateTime::Date
    stn::String
    ID::String
    prp::String
    var::NamedTuple
    varQuality::Float64
end

const expr_matchstatvar = r"\Avar\_"

const standard_code = Dict(
    "" => "Full"
)

"""
`standardize_var_name` standardize the direction suffix of a variable name.

For example,

```jldoctest
julia> standardize_var_name("S")
"S_Full"

julia> standardize_var_name("S_x")
"S_North"

julia> standardize_var_name("S_y")
"S_East"

julia> standardize_var_name("S_z")
"S_Down"

julia> standardize_var_name("S_EW")
"S_EW"

julia> standardize_var_name("S_NS")
"S_NS"
```

Additional prefix will be preserved:

```jldoctest
julia> standardize_var_name("var_S")
"var_S_Full"

julia> standardize_var_name("var_S_EW")
"var_S_EW"
```
"""
function standardize_var_name(s::AbstractString)
    sv = rsplit(s, "_", limit=2)

    if length(sv) == 1
        push!(sv, "")
    end
    sv[end] = standard_code[last(sv)]
    join(sv, "_")
end

function _statind_deser(T, path)
    stat = CSV.read(path, DataFrame)
    stat1 = @chain stat begin
        transform(AsTable(expr_matchstatvar) => ByRow(identity) => :var)
        select(Not(expr_matchstatvar))
    end
    rows = stat1 |> CSV.rowtable
    output = Serde.to_deser(Vector{T}, rows)
end

function Serde.deser(::Type{StatInd}, ::Type{Dates.Date}, data)
    return Dates.Date(data, info_date_format)
end
