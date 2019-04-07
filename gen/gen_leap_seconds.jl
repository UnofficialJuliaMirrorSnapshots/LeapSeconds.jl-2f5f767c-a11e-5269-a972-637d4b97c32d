using Dates

length(ARGS) != 1 && error("Need to provide the kernel number as an argument.")

num = lpad(ARGS[1], 4, "0")
file = "naif$num.tls"
url = "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/" * file
download(url, file)

const MJD = 2400000.5

t = Vector{Int}()
leapseconds = Vector{Float64}()
re = r"(?<dat>[0-9]{2}),\s+@(?<date>[0-9]{4}-[A-Z]{3}-[0-9])"
lines = open(readlines, file)
for line in lines
    s = string(line)
    if occursin(re, s)
        m = match(re, s)
        push!(leapseconds, parse(Float64, m["dat"]))
        push!(t, datetime2julian(DateTime(m["date"], "y-u-d")) - MJD)
    end
end

open("leap_seconds.jl", "w") do f
    write(f, """
    # Automatically generated by $(basename(@__FILE__)), do not edit!

    const LS_EPOCHS = [
        $(join(t, ",\n    ")),
    ]

    const LEAP_SECONDS = [
        $(join(leapseconds, ",\n    ")),
    ]
    """)
end
