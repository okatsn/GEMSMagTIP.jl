freq_bands = Base.ImmutableDict(
    "ULF_A" => (0.001, 0.003),
    "ULF_B" => (0.001, 0.01),
    "ULF_C" => (0.001, 0.1),
    "BP_35" => (0.00032, 0.0178),
    "BP_40" => (0.00010, 0.0178),
)

alternative_names = Base.ImmutableDict(
    "ULF-A" => freq_bands["ULF_A"],
    "ULF-B" => freq_bands["ULF_B"],
    "ULF-C" => freq_bands["ULF_C"],
    "BP-35" => freq_bands["BP_35"],
    "BP-40" => freq_bands["BP_40"],
)

# KEYNOTE: noted that merge two immutable dictionaries returns a mutable dictionary
const freq_bands_ext = Base.ImmutableDict([(k => v) for (k, v) in merge(freq_bands, alternative_names)]...)


"""
# Example

```jldoctest
julia> GEMSMagTIP.FreqBandDict()["ULF-C"]
(0.001, 0.1)
```
"""
struct FreqBandDict end

Base.getindex(::FreqBandDict, idx) =
    freq_bands_ext[idx]
