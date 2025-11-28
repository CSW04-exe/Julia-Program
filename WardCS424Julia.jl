# -----------------------------------------------------------------------------
# Author: Carter Ward
# Course: CS424-01 (Fall 2025)
# Date  : 10/20/2025
# Environment: VS Code with Julia 1.12.0
#
# Purpose:
#   Read a text file of player stats, compute eFG% and TS%, and print:
#     1) a report sorted by Last, First
#     2) a report sorted by TS% (descending)
#
# Notes:
#   - Data is stored as a matrix; each row is one player.
#   - Malformed rows are kept and flagged as "*missing input data*".
# -----------------------------------------------------------------------------

using Printf

# column indices
const FIRST=1; LAST=2; POINTS=4; FG_MADE=5; FG_ATT=6; TP_MADE=7; FT_ATT=10; BAD=11

# parse one line of text into a row
function parse_line(line::AbstractString)
    f = split(strip(line))
    if length(f) < 10
        first = length(f) >= 1 ? f[1] : ""
        last  = length(f) >= 2 ? f[2] : ""
        return [first,last,0,0,0,0,0,0,0,0,true]
    end
    nums = tryparse.(Int, f[3:10])
    any(x->x===nothing, nums) && return [f[1],f[2],0,0,0,0,0,0,0,0,true]
    return vcat(f[1:2], Int.(nums), false)
end

# read all players from file
function read_players(path::AbstractString)
    rows = Any[]
    open(path,"r") do io
        for ln in eachline(io)
            s = strip(ln); s=="" && continue
            push!(rows, parse_line(s))
        end
    end
    return reduce(vcat, permutedims.(rows))
end

# calculate stats
efg(r) = r[BAD] ? 0.0 : (r[FG_ATT]==0 ? 0.0 : (r[FG_MADE] + 0.5*r[TP_MADE]) / r[FG_ATT])
ts(r)  = r[BAD] ? 0.0 : ((d=2.0*(r[FG_ATT] + 0.44*r[FT_ATT]))==0 ? 0.0 : r[POINTS]/d)
total_points(mat) = sum(r[POINTS] for r in eachrow(mat) if !r[BAD])

# formatting  (aligned each player name to the right and added a colon afterward for readability)
const NAMEW=28
const NUMW=6
const SEP=" : "

header_line() = @sprintf("%*s%s%6s %6s", NAMEW, "PLAYER NAME", SEP, "eFG%", "TS%")

# full divider separating the header from the data section
# header width = NAMEW + length(" : ") + NUMW + 1 + NUMW
rule_line() = repeat("-", NAMEW + 3 + NUMW + 1 + NUMW)

function print_row(r)
    name = string(r[LAST], ", ", r[FIRST])
    if r[BAD]
        @printf("%*s%s%s\n", NAMEW, name, SEP, "*missing input data*")
    else
        @printf("%*s%s%6.1f %6.1f\n", NAMEW, name, SEP, efg(r)*100, ts(r)*100)
    end
end

# print both reports
function print_reports(mat)
    @printf("BASKETBALL TEAM REPORT --- %d PLAYERS FOUND IN FILE\n", size(mat,1))
    @printf("TOTAL POINTS SCORED: %d\n\n", total_points(mat))

    println(header_line()); println(rule_line())
    for r in eachrow(mat)
        print_row(r)
    end

    println()
    println("ORDERED BY TS%")
    println(header_line()); println(rule_line())
    idx = sortperm(eachrow(mat); by=r->r[BAD] ? -Inf : ts(r), rev=true)
    for i in idx
        print_row(mat[i,:])
    end
end

# main program
function main()
    print("Enter input filename: ")
    path = chomp(readline(stdin))
    mat  = read_players(path)
    mat  = mat[sortperm(eachrow(mat); by=r->(lowercase(r[LAST]),lowercase(r[FIRST]))), :]
    print_reports(mat)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
