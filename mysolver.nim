# Based on mysolver.py but written in nim.

# from pprint import pprint
import strutils
import strformat
import times

# let INITIAL_GRID = [
#     [5, 3, 0, 0, 7, 0, 0, 0, 0],
#     [6, 0, 0, 1, 9, 5, 0, 0, 0],
#     [0, 9, 8, 0, 0, 0, 0, 6, 0],
#     [8, 0, 0, 0, 6, 0, 0, 0, 3],
#     [4, 0, 0, 8, 0, 3, 0, 0, 1],
#     [7, 0, 0, 0, 2, 0, 0, 0, 6],
#     [0, 6, 0, 0, 0, 0, 2, 8, 0],
#     [0, 0, 0, 4, 1, 9, 0, 0, 5],
#     # [0, 0, 0, 0, 8, 0, 0, 7, 9],  # <-- only one possible solution
#     [0, 0, 0, 0, 8, 0, 0, 0, 0],  # <-- two possible solutions
# ]

# let INITIAL_GRID = [
#     [0, 0, 1, 2, 7, 0, 9, 0, 0],
#     [0, 4, 9, 1, 3, 8, 0, 0, 0],
#     [0, 0, 7, 0, 4, 5, 0, 1, 3],
#     [3, 7, 0, 0, 2, 9, 0, 6, 1],
#     [1, 8, 5, 3, 0, 0, 0, 0, 9],
#     [9, 0, 0, 0, 0, 4, 0, 7, 8],
#     [0, 0, 6, 7, 0, 0, 0, 0, 2],
#     [2, 1, 8, 6, 0, 3, 0, 0, 5],
#     [0, 0, 0, 0, 0, 0, 0, 0, 0],
# ]

# # Project Euler Puzzle 96 - First easy puzzle
# let INITIAL_GRID = [
#     [0,0,3,0,2,0,6,0,0],
#     [9,0,0,3,0,5,0,0,1],
#     [0,0,1,8,0,6,4,0,0],
#     [0,0,8,1,0,2,9,0,0],
#     [7,0,0,0,0,0,0,0,8],
#     [0,0,6,7,0,8,2,0,0],
#     [0,0,2,6,0,9,5,0,0],
#     [8,0,0,2,0,3,0,0,9],
#     [0,0,5,0,1,0,3,0,0],
# ]

# Hard puzzle #1 from http://magictour.free.fr/top95
let INITIAL_GRID = [
    [4,0,0,0,0,0,8,0,5],
    [0,3,0,0,0,0,0,0,0],
    [0,0,0,7,0,0,0,0,0],
    [0,2,0,0,0,0,0,6,0],
    [0,0,0,0,8,0,4,0,0],
    [0,0,0,0,1,0,0,0,0],
    [0,0,0,6,0,3,0,7,0],
    [5,0,0,2,0,0,0,0,0],
    [1,0,4,0,0,0,0,0,0],
]

# # https://projecteuler.net/problem=96
# let INITIAL_GRID = [
#     [0, 0, 3, 0, 2, 0, 6, 0, 0],
#     [9, 0, 0, 3, 0, 5, 0, 0, 1],
#     [0, 0, 1, 8, 0, 6, 4, 0, 0],
#     [0, 0, 8, 1, 0, 2, 9, 0, 0],
#     [7, 0, 0, 0, 0, 0, 0, 0, 8],
#     [0, 0, 6, 7, 0, 8, 2, 0, 0],
#     [0, 0, 2, 6, 0, 9, 5, 0, 0],
#     [8, 0, 0, 2, 0, 3, 0, 0, 9],
#     [0, 0, 5, 0, 1, 0, 3, 0, 0],
# ]

type
    Grid = array[9, array[9, int]]

# let INITIAL_GRID = [
#     [0, 0, 3, 0, 2, 0, 6, 0, 0],
#     [9, 0, 0, 3, 0, 5, 0, 0, 1],
#     [0, 0, 1, 8, 0, 6, 4, 0, 0],
#     [0, 0, 8, 1, 0, 2, 9, 0, 0],
#     [0, 0, 0, 0, 0, 0, 0, 0, 8],
#     [0, 0, 0, 0, 0, 8, 2, 0, 0],
#     [0, 0, 0, 0, 0, 0, 5, 0, 0],
#     [8, 0, 0, 0, 0, 3, 0, 0, 9],
#     [0, 0, 0, 0, 0, 0, 3, 0, 0],
# ]


proc `$`(grid: Grid): string =
    var lines: seq[string] = @[]
    for y in 0 ..< grid.len:
        if y mod 3 == 0 and y > 0:
            lines.add("-------+-------+-------")
        
        let row = grid[y]       
        var rowStr: string
        for x, c in row:
            # echo x
            let divisibleBy3 = x mod 3 == 0
            if divisibleBy3 and x > 0:
                rowStr.add(" |")
            if c == 0:
                rowStr.add("  ")  # blank
            else:
                rowStr.add(" " & $c)
        lines.add(rowStr)
    result = lines.join("\n")

proc displayGrid(grid: Grid) =
    # for y in 0 ..< grid.len:
    #     if y mod 3 == 0 and y > 0:
    #         echo "-------+-------+-------"
        
    #     let row = grid[y]       
    #     var rowStr: string
    #     for x, c in row:
    #         # echo x
    #         let divisibleBy3 = x mod 3 == 0
    #         if divisibleBy3 and x > 0:
    #             rowStr.add(" |")
    #         if c == 0:
    #             rowStr.add("  ")  # blank
    #         else:
    #             rowStr.add(" " & $c)
    #     echo rowStr
    echo $grid


echo "Start:"
displayGrid(INITIAL_GRID)

proc possible(grid: Grid, row: int, col: int, n: int): bool =
    
    # Scan column for n
    for y in 0 ..< 9:
        if grid[y][col] == n:
            return false
    
    # Scan row for n
    for x in 0 ..< 9:
        if grid[row][x] == n:
            return false
    
    # Scan box for n; box = a box of 9 cells of the nine 3x3 boxes in a grid
    let
        box_y = row div 3  #int(row / 3)
        box_x = col div 3  #int(col / 3)
        y_min = box_y * 3
        y_max = y_min + 3
        x_min = box_x * 3
        x_max = x_min + 3
    for y in y_min ..< y_max:
        for x in x_min ..< x_max:
            if grid[y][x] == n:
                return false
    
    return true

type
    SolverFinished = object of CatchableError


proc solver(sudoku: Grid): seq[Grid] =
    var modified_cells: seq[array[2, int]]
    var values: seq[int] = @[]

    # Go through each empty cell in the grid
    var 
        y = 0
        x = 0
        n = 1
    
    var grid = sudoku

    try:
        while true:
            while y < 9:
                x = 0
                while x < 9:
                    # echo "x: ", x
                    if grid[y][x] == 0:  # Current cell is empty

                        # Attempt to see if each number is possible on the current empty cell
                        while n < 10:
                            if possible(grid, y, x, n):
                                # grid[y][x] = n  # Fill cell
                                # solver()  # Find next empty to next cell
                                # grid[y][x] = 0  # backtrack
                                break
                            n += 1  # try next number...

                        if n == 10:
                            # echo modified_cells
                            if len(modified_cells) > 0:
                                # All numbers attempted (all not possible), so rewind stack by 1
                                (y, x) = modified_cells.pop()
                                grid[y][x] = 0  # clear the cell so it can be found by if-condition above
                                n = values.pop() + 1
                                # echo fmt"backtrack: ({y}, {x}), n={n}"
                                continue
                            else:
                                # Unable to rewind anymore
                                raise new SolverFinished
                        else:
                            grid[y][x] = n  # Fill cell
                            values.add(n)
                            modified_cells.add([y, x])
                            n = 1
                        # return
                    x += 1
                y += 1
            
            # Solved - all white spaces filled
            # var solved: array[9, array[9, int]]
            # solved = grid
            # result.add(solved)
            result.add(grid)
            # pprint(grid)
            # input("More?")

            # Rewind stack so we can attempt other numbers
            (y, x) = modified_cells.pop()
            grid[y][x] = 0  # clear the cell so it can be found by if-condition above
            n = values.pop() + 1
    except SolverFinished:
        echo "Solver finished"
    return result



# assert possible(4, 4, 5) is True
# assert possible(4, 4, 3) is False

let startTime = getTime()
let results = solver(INITIAL_GRID)
# let results: seq[Grid] = @[]
let endTime = getTime()

# echo "startTime: ", startTime
# echo "endTime: ", endTime

echo "Solved:"
for solved in results:
    # displayGrid(solved)
    echo $solved
    echo ""
echo fmt"{len(results)} solutions found"


let elapsedTime = endTime - startTime
echo "elapsedTime: ", elapsedTime
