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
