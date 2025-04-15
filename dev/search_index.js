var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GEMSMagTIP","category":"page"},{"location":"#GEMSMagTIP","page":"Home","title":"GEMSMagTIP","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for GEMSMagTIP.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GEMSMagTIP]","category":"page"},{"location":"#GEMSMagTIP.expr_matchstatvar","page":"Home","title":"GEMSMagTIP.expr_matchstatvar","text":"Matches \"varSEEW\".\n\n\n\n\n\n","category":"constant"},{"location":"#GEMSMagTIP.expr_matchstatvarrest","page":"Home","title":"GEMSMagTIP.expr_matchstatvarrest","text":"Matches \"SEEW\" for \"varSE_EW\".\n\n\n\n\n\n","category":"constant"},{"location":"#GEMSMagTIP.file_bestmodels","page":"Home","title":"GEMSMagTIP.file_bestmodels","text":"This file name is shared with GEMS-MagTIP-insider data processing.\n\nIf this constant has been modified, in matlab scripts which use statind_summary.m and jointstation_summary.m the output file names have also be modified.\n\n\n\n\n\n","category":"constant"},{"location":"#GEMSMagTIP.file_fittingdegree","page":"Home","title":"GEMSMagTIP.file_fittingdegree","text":"This file name is shared with GEMS-MagTIP-insider data processing.\n\nIf this constant has been modified, in matlab scripts which use statind_summary.m and jointstation_summary.m the output file names have also be modified.\n\n\n\n\n\n","category":"constant"},{"location":"#GEMSMagTIP.file_statind","page":"Home","title":"GEMSMagTIP.file_statind","text":"This file name is shared with GEMS-MagTIP-insider data processing.\n\nIf this constant has been modified, in matlab scripts which use statind_summary.m and jointstation_summary.m the output file names have also be modified.\n\n\n\n\n\n","category":"constant"},{"location":"#GEMSMagTIP.NotSupported-Tuple{String}","page":"Home","title":"GEMSMagTIP.NotSupported","text":"How to use: throw(NotSupported(\"CSV serialization\")). How to test: @test_throws GEMSMagTIP.NotSupported ...\n\n\n\n\n\n","category":"method"},{"location":"#GEMSMagTIP.StatInd","page":"Home","title":"GEMSMagTIP.StatInd","text":"struct StatInd\n    DateTime::Date\n    stn::String\n    prp::String\n    var::NamedTuple\nend\n\ndf = GEMSMagTIP.read_data(file, DataFrame).\n\nTo revert df the same columns as the csv file:\n\n@chain df begin\n    transform(:var => AsTable)\n    select(Not(:var))\n    transform(:DateTime => ByRow(t -> Dates.format(t, GEMSMagTIP.info_date_format)); renamecols=false)\nend\n\n\n\n\n\n","category":"type"},{"location":"#GEMSMagTIP.core_read","page":"Home","title":"GEMSMagTIP.core_read","text":"core_read(path) attempts to infer T for Serde.to_deser(Vector{T}, ...) for CSV deserialization based on the file name in path. See GEMSMagTIP.file_ + [tab] for the supported file names.\n\nThis means core_read is designed to be dispatched over the Val of specific file name (e.g., file_fitting degree) that is associated to a specific concrete struct (e.g., FittingDegree), rather than dispatched by a concrete struct.\n\n\n\n\n\n","category":"function"},{"location":"#GEMSMagTIP.process_before_deser-Tuple{Type{<:GEMSMagTIP.CSVRow}, Any}","page":"Home","title":"GEMSMagTIP.process_before_deser","text":"Internally called _vec_deser, and returns CSV.rowtable whose columns match fields in T.\n\n\n\n\n\n","category":"method"},{"location":"#GEMSMagTIP.read_data-Tuple{Any, Any}","page":"Home","title":"GEMSMagTIP.read_data","text":"read_data(path, DataFrame) dispatch deserialization by file name. For example, if basename(path) is StatInd.csv, it returns the DataFrame with each row being StatInd.\n\nIn this case, it is equivalent as calling read_data(StatInd, path, DataFrame).\n\n\n\n\n\n","category":"method"},{"location":"#GEMSMagTIP.read_data-Tuple{Type{<:GEMSMagTIP.CSVRow}, Any, Any}","page":"Home","title":"GEMSMagTIP.read_data","text":"read_data(T::Type{<:CSVRow}, path, sink) deserialize data to type T for arbitrary file name, and finally returned as data of type sink.\n\nExample\n\nusing GEMSMagTIP\nGEMSMagTIP.read_data(StatInd, \"data.csv\", DataFrame)\n\n\n\n\n\n","category":"method"},{"location":"#GEMSMagTIP.standardize_var_suffix-Tuple{AbstractString}","page":"Home","title":"GEMSMagTIP.standardize_var_suffix","text":"standardize_var_suffix standardize the direction suffix of a variable name.\n\nFor example,\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S\")\n\"S_Full\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S_x\")\n\"S_North\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S_y\")\n\"S_East\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S_z\")\n\"S_Down\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S_EW\")\n\"S_EW\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"S_NS\")\n\"S_NS\"\n\nAdditional prefix of \"var_\" will be preserved:\n\njulia> GEMSMagTIP.standardize_var_suffix(\"var_S\")\n\"var_S_Full\"\n\njulia> GEMSMagTIP.standardize_var_suffix(\"var_S_EW\")\n\"var_S_EW\"\n\n\n\n\n\n","category":"method"},{"location":"#GEMSMagTIP.varstr2nt-Tuple{Any}","page":"Home","title":"GEMSMagTIP.varstr2nt","text":"For transforming :variable to :var_type and :var_comp.\n\nExample\n\ntransform(:variable => ByRow(v -> varstr2nt) => AsTable)\n\n\n\n\n\n","category":"method"}]
}
