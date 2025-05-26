# https://www.youtube.com/watch?v=G_UYXzGuqvM
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
#     # [0, 0, 0, 0, 8, 0, 0, 7, 9],

#     [0, 0, 0, 0, 8, 0, 0, 0, 0],
# ]

grid = [
    [0, 0, 1, 2, 7, 0, 9, 0, 0],
    [0, 4, 9, 1, 3, 8, 0, 0, 0],
    [0, 0, 7, 0, 4, 5, 0, 1, 3],
    [3, 7, 0, 0, 2, 9, 0, 6, 1],
    [1, 8, 5, 3, 0, 0, 0, 0, 9],
    [9, 0, 0, 0, 0, 4, 0, 7, 8],
    [0, 0, 6, 7, 0, 0, 0, 0, 2],
    [2, 1, 8, 6, 0, 3, 0, 0, 5],
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
]

# https://projecteuler.net/problem=96
# grid = [
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

def solver():
    # Go through each [empty] cell in the grid
    for y in range(9):
        for x in range(9):
            if grid[y][x] == 0:
                # Current cell is empty

                # Attempt to see if each number is possible on the current empty cell
                for n in range(1, 10):
                    if possible(y, x, n):
                        grid[y][x] = n  # Fill cell
                        solver()  # Find next empty to next cell
                        grid[y][x] = 0  # backtrack
                    # try next number...

                # All numbers attempted (all not possible), so rewind stack by 1
                return
    
    # Solved - all white spaces filled
    pprint(grid)
    input("More?")



# assert possible(4, 4, 5) is True
# assert possible(4, 4, 3) is False

print("Solved:")
solver()