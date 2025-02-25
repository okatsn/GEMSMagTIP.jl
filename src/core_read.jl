function core_read(path)
    fname = basename(path)
    core_read(fname, path)
end
core_read(fname::String, path) = core_read(Symbol(fname), path)
core_read(fname::Symbol, path) = core_read(Val(fname), path) # then dispatch by Val(fname) to functions in other src file.
