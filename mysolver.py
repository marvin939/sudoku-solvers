# Based on the computerphile Sudoku solver, but converted into an iterative solution as opposed to recursive for FUN :-).

import datetime
from pprint import pprint

# grid = [
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

# https://projecteuler.net/problem=96
grid = [
    [0, 0, 3, 0, 2, 0, 6, 0, 0],
    [9, 0, 0, 3, 0, 5, 0, 0, 1],
    [0, 0, 1, 8, 0, 6, 4, 0, 0],
    [0, 0, 8, 1, 0, 2, 9, 0, 0],
    [7, 0, 0, 0, 0, 0, 0, 0, 8],
    [0, 0, 6, 7, 0, 8, 2, 0, 0],
    [0, 0, 2, 6, 0, 9, 5, 0, 0],
    [8, 0, 0, 2, 0, 3, 0, 0, 9],
    [0, 0, 5, 0, 1, 0, 3, 0, 0],
]

# grid = [
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


print("Start:")
pprint(grid)

def possible(row: int, col: int, n: int) -> bool:
    result = False
    
    # Scan column for n
    for y in range(9):
        if grid[y][col] == n:
            return False
    
    # Scan row for n
    for x in range(9):
        if grid[row][x] == n:
            return False
    
    # Scan box for n; box = a box of 9 cells of the nine 3x3 boxes in a grid
    box_y = int(row / 3)
    box_x = int(col / 3)
    y_min = box_y * 3
    y_max = y_min + 3
    x_min = box_x * 3
    x_max = x_min + 3
    for y in range(y_min, y_max):
        for x in range(x_min, x_max):
            if grid[y][x] == n:
                return False
    
    return True

class SolverFinished(Exception): pass

def solver():
    modified_cells = []
    values = []

    # Go through each empty cell in the grid
    x, y = 0, 0
    n = 1

    results = []

    try:
        while True:
            while y < 9:
                x = 0
                while x < 9:
                    
                    if grid[y][x] == 0:  # Current cell is empty

                        # Attempt to see if each number is possible on the current empty cell
                        while n < 10:
                            if possible(y, x, n):
                                # grid[y][x] = n  # Fill cell
                                # solver()  # Find next empty to next cell
                                # grid[y][x] = 0  # backtrack
                                break
                            n += 1  # try next number...

                        if n == 10:
                            if len(modified_cells) > 0:
                                # All numbers attempted (all not possible), so rewind stack by 1
                                y, x = modified_cells.pop()
                                grid[y][x] = 0  # clear the cell so it can be found by if-condition above
                                n = values.pop() + 1
                                continue
                            else:
                                # Unable to rewind anymore
                                raise SolverFinished()
                        else:
                            grid[y][x] = n  # Fill cell
                            values.append(n)
                            modified_cells.append((y, x))
                            n = 1
                        # return
                    x += 1
                y += 1
            
            # Solved - all white spaces filled
            results.append([[c for c in r] for r in grid])
            # pprint(grid)
            # input("More?")

            # Rewind stack so we can attempt other numbers
            y, x = modified_cells.pop()
            grid[y][x] = 0  # clear the cell so it can be found by if-condition above
            n = values.pop() + 1
    except SolverFinished:
        return results



# assert possible(4, 4, 5) is True
# assert possible(4, 4, 3) is False

start_time = datetime.datetime.now()
results = solver()
end_time = datetime.datetime.now()
print(f"Solved:")
pprint(results)
print(f"{len(results)} solutions found")
print(f"elapsedTime: {end_time - start_time}")
print(f"elapsedTime: {end_time - start_time!r}")