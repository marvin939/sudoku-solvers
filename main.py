
def cross(A, B):
    "Cross product of elements in A and elements in B."
    return [a+b for a in A for b in B]

digits = "123456789"
rows = "ABCDEFGHI"
cols = digits
squares = cross(rows, cols)
print(squares)


unitlist_columns = [cross(rows, c) for c in cols]
print(f"{unitlist_columns=}")

unitlist_rows = [cross(r, cols) for r in rows]
print(f"{unitlist_rows=}")

unitlist_boxes = [cross(rs, cs) for rs in ("ABC", "DEF", "GHI") for cs in ("123", "456", "789")]
# e.g.
# [['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3'], 
#  ['A4', 'A5', 'A6', 'B4', 'B5', 'B6', 'C4', 'C5', 'C6'], 
#  ['A7', 'A8', 'A9', 'B7', 'B8', 'B9', 'C7', 'C8', 'C9'], 
#  ['D1', 'D2', 'D3', 'E1', 'E2', 'E3', 'F1', 'F2', 'F3'], 
#  ['D4', 'D5', 'D6', 'E4', 'E5', 'E6', 'F4', 'F5', 'F6'], 
#  ['D7', 'D8', 'D9', 'E7', 'E8', 'E9', 'F7', 'F8', 'F9'], 
#  ['G1', 'G2', 'G3', 'H1', 'H2', 'H3', 'I1', 'I2', 'I3'], 
#  ['G4', 'G5', 'G6', 'H4', 'H5', 'H6', 'I4', 'I5', 'I6'], 
#  ['G7', 'G8', 'G9', 'H7', 'H8', 'H9', 'I7', 'I8', 'I9']]
print(f"{unitlist_boxes=}")
unitlist = (unitlist_columns + unitlist_rows + unitlist_boxes)

units = dict((s, [u for u in unitlist if s in u])
             for s in squares)
# Keys are squares, values are units pertaining to that square (key).
# Each square has three units - the column unit, row unit and unit unit

peers = dict((s, set(sum(units[s], [])) - set([s]))
             for  s in squares)


def test():
    "A set of unit tests."
    assert len(squares) == 81  # = 3 * 3 squares
    assert len(unitlist) == 27  # 9 row units + 9 column units + 9 box units
    assert all(len(units[s]) == 3 for s in squares)  # all squares have 3 units
    assert all(len(peers[s]) == 20 for s in squares)  # all squares have 20 peers
    assert units["C2"] == [['A2', 'B2', 'C2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2'],
                           ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9'],
                           ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']]
    assert peers['C2'] == set(['A2', 'B2', 'D2', 'E2', 'F2', 'G2', 'H2', 'I2',
                               'C1', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9',
                               'A1', 'A3', 'B1', 'B3'])
    print("All tests pass.")

test()

# All the following strings are valid representations of a sudoku puzzle that the program can parse.
"4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"

"""
400000805
030000000
000700000
020000060
000080400
000010000
000603070
500200000
104000000"""

"""
4 . . |. . . |8 . 5 
. 3 . |. . . |. . . 
. . . |7 . . |. . . 
------+------+------
. 2 . |. . . |. 6 . 
. . . |. 8 . |4 . . 
. . . |. 1 . |. . . 
------+------+------
. . . |6 . 3 |. 7 . 
5 . . |2 . . |. . . 
1 . 4 |. . . |. . . 
"""

def parse_grid(grid):
    """Convert grid to a dict of possible values, {square: digits}, or
    return False of if a contradiction is detected."""
    ## To start, every square acan be any digit; then assign values from the grid.

    # every square can be any digit
    values = dict((s, digits) for s in squares)  # s = 123456789 if we're uncertain.

    # then assign values from the grid
    for s, d in grid_values(grid).items():
        if d in digits and not assign(values, s, d):
            return False  # (Fail if we can't assign d to square s.)
    return values
    # e.g. {"A1": "7", "C7": "123456789", ...}

def grid_values(grid):
    "Convert grid into a dict of {square: char} with '0' or '.' for empties."
    chars = [c for c in grid if c in digits or c in "0."]
    assert len(chars) == 81
    return dict(zip(squares, chars))

