# Based on the sudoku solver from the following page:
# https://norvig.com/sudoku.html

# from pprint import pprint
import strutils
import strformat
import sequtils
import times
import tables
import sets
import sugar
import os
import parseopt


proc cross(A: string, B: string): seq[string] =
    for a in A:
        for b in B:
            result.add(a & b)

proc cross(A: string, B: char): seq[string] =
    for a in A:
        result.add(a & B)

proc cross(A: char, B: string): seq[string] =
    for b in B:
        result.add(A & b)

let digits = "123456789"
let rows = "ABCDEFGHI"
let cols = digits
let squares = cross(rows, digits)
var unitlist: seq[seq[string]]
block BuildUnitList:
    for c in cols:
        unitlist.add(cross(rows, c))
    for r in rows:
        unitlist.add(cross(r, cols))
    for cs in ["123", "456", "789"]:
        for rs in ["ABC", "DEF", "GHI"]:
            unitlist.add(cross(rs, cs))

var units = Table[string, seq[seq[string]]]()
block BuildUnits:
    for s in squares:
        units[s] = @[]
        for u in unitlist:
            if s in u:
                units[s] &= u
# echo units["A1"]

#var peers = Table[string, HashSet[string]]()
var peers = Table[string, seq[string]]()
block BuildPeers:
    for s in squares:
        var square_peers: HashSet[string]
        for u in units[s]:
            square_peers = square_peers + toHashSet(u)
        square_peers = square_peers - toHashSet([s])
        # peers[s] = square_peers
        peers[s] = square_peers.toSeq
# echo peers["A1"]

proc test() =
    # A set of unit tests.
    assert len(squares) == 81
    assert len(unitlist) == 27

    assert peers["A1"].len == 20
    # Check all squares have 3 units:
    assert squares.all(proc (s: string): bool = (units[s].len == 3))
    # Check all squares have 20 peers:
    assert squares.all(proc (s: string): bool = (peers[s].len == 20))

    # echo units["C2"]
    assert units["C2"] == @[
        @["A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2", "I2"],
        @["C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9"],
        @["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]]

    # assert peers["C2"] == toHashSet(
    # echo "peers[\"C2\"] = ", peers["C2"]
    assert peers["C2"].toHashSet == [
        "A2", "B2", "D2", "E2", "F2", "G2", "H2", "I2",
        "C1", "C3", "C4", "C5", "C6", "C7", "C8", "C9",
        "A1", "A3", "B1", "B3"].toHashSet
        
    echo "All tests pass."

test()

type
    GridValues = Table[string, string]

# proc assign(values: Table[string, string], s: string, d: string): Table[string, string]
proc assign(values: var GridValues, s: string, d: string): bool
proc grid_values(grid: string): GridValues
proc eliminate(values: var GridValues, s: string, d: string): bool

proc parse_grid*(grid: string): GridValues =
    #[Convert grid to a dict of possible values, {square: digits}, or 
    return False if a contradiction is detected.]#
    var values: Table[string, string]
    for s in squares:
        values[s] = digits
    for s, d in grid_values(grid):
        # echo "[parse_grid] s: ", s, ", d: ", d
        if d in digits and not assign(values, s, d):
            return initTable[string, string]()
    return values


proc grid_values(grid: string): GridValues =
    #[ Convert grid into a table of {square: char} with '0' or '.' for empties. ]#
    var chars: string
    for c in grid:
        if c in digits or c in "0.":
            chars &= c
    assert len(chars) == 81
    for i, s in squares:
        result[s] = $chars[i]
    # echo "grid_values: ", result
    return result

proc assign(values: var GridValues, s: string, d: string): bool =
    #[ Eliminitae all other values (except d) from values[s] and propagate.
    Return values, except return False if a contradiction is detected. ]#
    let other_values = values[s].replace(d, "")
    # if other_values.all(proc (d2: char): bool = return eliminate(values, s, $d2)):
    #     # result = values
    #     return true
    # else:
    #     return false
    var eliminate_results: seq[bool]
    for d2 in other_values:
        let eliminated = eliminate(values, s, $d2)
        eliminate_results.add(eliminated)
    
    for r in eliminate_results:
        if r == false:
            # echo "[assign] eliminate values: ", values
            return false
    return true


proc eliminate(values: var GridValues, s: string, d: string): bool =
    #[ Eliminate d from values[s]; propagate when values or places <= 2.
    Return values, except return empty table if a contradiction is detected. ]#
    
    if not (d in values[s]):
        return true  # Already eliminated
    values[s] = values[s].replace(d, "")
    # (1) If a square s is reduced to one value, then eliminate d2 from the peers.
    if len(values[s]) == 0:
        return false  # Contradiction: removed last value
    elif len(values[s]) == 1:
        let d2 = values[s]
        #if not peers[s].all(proc (s2: string): bool = return (eliminate(values, s2, d2).len > 0)):
        # if not peers[s].map(proc (s2: string): bool = eliminate(values, s2, d2).len > 0).all():
        # if not all(peers[s], proc (s2: string): bool = return eliminate(values, s2, d2)):
        #     return false
        var eliminate_results: seq[bool]
        for s2 in peers[s]:
            # if not eliminate(values, s2, d2):
            #     return false
            eliminate_results.add(eliminate(values, s2, d2))
        for r in eliminate_results:
            if r == false:
                return false
    # (2) If a unit u is reduced to only one place for a value d, then put it there.
    for u in units[s]:
        var dplaces: seq[string]
        for s in u:
            if d in values[s]: dplaces.add(s)
        if len(dplaces) == 0:
            return false  # Contradiction: no place for this value
        elif len(dplaces) == 1:
            # d can only be in one place in unit; assign it there
            # if not assign(values, dplaces[0], d):
            if not assign(values, dplaces[0], d):
                return false
    return true

proc display*(values: GridValues) =
    # Display these values as a 2D grid.
    # let maxValuesLen = max(values.values.toSeq.map(x => x.len))
    
    var maxValuesLen: int
    for val in values.values.toSeq:
        # echo "val: ", val
        maxValuesLen = max(maxValuesLen, len(val))
    # echo "maxValuesLen: ", maxValuesLen

    let width = maxValuesLen + 1
    
    # Create horizontal line
    var temp: seq[string]
    for x in 0 ..< 3:
        temp.add("-".repeat(width * 3))
    let line: string = temp.join("+")
    # echo line

    for r in rows:
        temp = @[]
        for c in cols:
            var cell: string
            cell = values[r & c].center(width)
            if c in "36":
                cell &= "|"
            temp.add(cell)
        # echo ().join("")
        echo temp.join("")
        if r in "CF":
            echo line

#let grid1 = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"
# let grid1 = "003020600900305001001806400008102900700000008006708200002609500800203009005010300"
# let parsed_grid = parse_grid(grid1)
# echo "grid1: ", grid1
# echo "parsed_grid: ", parsed_grid
# echo "parsed_grid type: ", type(parsed_grid)
# assert len(parsed_grid) == 81
# echo "Parsed grid / starting grid:"
# display(parsed_grid)
# Should be completely solved by parser since this is one of the easier Project Euler sudoku puzzles


proc search(values: var GridValues): bool

proc solve*(grid: string): GridValues =
    var values = parse_grid(grid)
    # echo "Starting grid:"
    # display(values)
    let solved = search(values)
    assert solved == true
    return values

proc solve*(values: GridValues): GridValues =
    var valuesCopy = values
    let solved = search(valuesCopy)
    assert solved == true
    return valuesCopy

proc search(values: var Table[string, string]): bool =
    # Using depth-first search and propagation, try all possible values.

    if values.values.toSeq.all(proc (vals: string): bool = vals.len() == 1):
        return true  # Solved!

    # Choose the unfilled square s with the fewest possibilities
    var s: string
    var n: int = 999
    for s2, v in values:
        let numValues = len(v)
        if numValues < n and numValues > 1:
            s = s2
            n = numValues
    #         echo "s=", s, "; n=", n, "; v=", v
    # echo "unfilled square with fewest possibilities: s=", s, "; n=", n
    # display(values)

    for d in values[s]:
        var valuesCopy = values
        let assigned = assign(valuesCopy, s, $d)
        if assigned:
            let solveSuccess = search(valuesCopy)
            if solveSuccess:
                values = valuesCopy  # Copy solution to values
                # echo "assigned/valuesCopy:"
                # display(valuesCopy)
                # echo "Solved!!!"
                return solveSuccess
    return false

proc gridValuesAsString(grid: GridValues): string =
    var lines: seq[string] = @[]
    let rowSeparator = "-------+-------+-------"
    for y, row in rows:
        
        # let row = grid[y]       
        var rowStr: string
        # echo "row: ", row
        for x, col in cols:
            let cellValues = grid[row & col]
            if len(cellValues) > 1 or (len(cellValues) == 1 and cellValues[0] in "0."):
                # Display as blank as there are multiple possible values for the cell
                rowStr.add(" -")  
            else:
                rowStr.add(" " & cellValues)
            
            if col in "36":
                rowStr.add(" |")
        lines.add(rowStr & " ".repeat(len(rowSeparator) - len(rowStr)))
        if row in "CF":
            lines.add(rowSeparator)
    result = lines.join("\n")

proc displayTwoGridValues*(grid1: GridValues, grid2: GridValues, grid1_name: sink string, grid2_name: string) =
    var grid1_lines = gridValuesAsString(grid1).splitLines()
    var grid2_lines = gridValuesAsString(grid2).splitLines()

    grid1_name = grid1_name & ":"
    echo fmt"{grid1_name:<26} {grid2_name}:"
    for i, (grid1_line, grid2_line) in zip(grid1_lines, grid2_lines):
        # echo grid1_line & "      " & grid2_line
        echo fmt"{grid1_line:<26} {grid2_line}"
        # echo "grid1_line: ", grid1_line
        # echo "grid2_line: ", grid2_line


proc solveFile(filePath: string) =
    # Solve and display results of all sudokus puzzles in a file
    echo "Solving..."

    const allowedChars = "0123456789."
    const allowedCharSet = allowedChars.toSet()

    var contents: string
    var grids: seq[string]
    for line in readFile(filePath).strip().splitLines():
        var line = line.strip()
        if line.len < 9:
            continue

        if not (line.toSet <= allowedCharSet):
            # line's character isn't a subset of allowedCharSet.
            continue
        # var skipLine = false
        # for c in line:
        #     if not (c in allowedChars):
        #         skipLine = true
        #         break
        # if skipLine:
        #     continue

        contents &= line
        while contents.len >= len(squares):
            grids.add(contents[0 ..< len(squares)])
            contents = contents[len(squares) ..< len(contents)]

    var parsedGrids: seq[GridValues]  # Contains grids with potential values for each cell (partially solved)
    var unparsedGrids: seq[GridValues]  # Contains grids in their initial, unsolved state
    
    for grid in grids:
        let parsedGrid = parse_grid(grid)
        parsedGrids.add(parsedGrid)
        
        let unparsedGrid: GridValues = grid_values(grid)
        unparsedGrids.add(unparsedGrid)
    
    for i, grid in parsedGrids:
        var solvedGrid = solve(grid)
        displayTwoGridValues(unparsedGrids[i], solvedGrid, fmt"Puzzle #{i + 1}", "Solved")
        echo ""
          

proc main() =

    var stringArg1: string

    for (kind, key, val) in getopt(commandLineParams()):
        case kind:
        of cmdArgument:
            stringArg1 = key
            echo "Argument: ", key
        of cmdLongOption, cmdShortOption:
            if val == "":
                echo "Option: ", key
            else:
                echo "Option and value: ", key, ", ", val
        of cmdEnd:
            doAssert(false)

    if isEmptyOrWhitespace(stringArg1):
        echo "No parameters detected. Have a demo instead."
        let grid2 = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"
        let parsed = parse_grid(grid2)
        # echo "Parsed:"
        # echo parsed
        # display(parsed)
        let solved = solve(parsed)
        # echo "Solved:"
        # display(solved)

        # echo "Parsed:"
        # echo gridValuesAsString(parsed)

        echo ""
        displayTwoGridValues(parsed, solved, "Parsed", "Solved")
        echo ""
    
    # echo "stringArg1: " & stringArg1
    if fileExists(stringArg1):
        echo "Passed parameter is a file."
        solveFile(stringArg1)
    else:
        # Attempt to solve
        try:
            let parsed = parse_grid(stringArg1)
            let solved = solve(parsed)
            echo ""
            displayTwoGridValues(parsed, solved, "Parsed", "Solved")
            echo ""
        except AssertionDefect as exc:
            echo "Unable to convert string argument to sudoku puzzle."
            echo "Goodbye!"
    

main()