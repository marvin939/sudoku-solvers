# Sudoku Solvers
A tiny collection of sudoku solvers made in Nim and Python to help me learn the Nim programming language.
## norvigsudoku.nim
A sudoku solver solver based on the following page by Peter Norvig:

https://norvig.com/sudoku.html

I tried to keep this as close to the original as possible without attempting to use a lot syntactic-sugar features as I was more interested in getting something working while maintaining a level of readability and translate-ability to other programming languages using basic programming constructs only.

### How to use:

#### Compiling and running the solver
```
$ nim c -r norvigsudoku.nim
```
This will produce an executable, `norvigsudoku` (Linux) or `norvigsudoku.exe` (Windows), which you can run in the terminal. By default it will attempt to solve the following pre-defined grid:
`4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......`


#### Solving a single sudoku puzzle
```
$ ./norvigsudoku ".4.............8...5...3........................7..............2.............6............8....4..............1.................6...3....7...5......2.....
.......1...4.............."
```
or
```
$ nim c -r norvigsudoku.nim "400000805
030000000
000700000
020000060
000080400
000010000
000603070
500200000
104000000"
```
...which produces the following output:
```
Parsed:                    Sovled:
 4 - - | - - - | 8 - 5      4 1 7 | 3 6 9 | 8 2 5 
 - 3 - | - - - | - - -      6 3 2 | 1 5 8 | 9 4 7 
 - - - | 7 - - | - - -      9 5 8 | 7 2 4 | 3 1 6 
-------+-------+-------    -------+-------+-------
 - 2 - | - - - | - 6 -      8 2 5 | 4 3 7 | 1 6 9 
 - - - | - 8 - | 4 - -      7 9 1 | 5 8 6 | 4 3 2 
 - 4 - | - 1 - | - - -      3 4 6 | 9 1 2 | 7 5 8 
-------+-------+-------    -------+-------+-------
 - - - | 6 - 3 | - 7 -      2 8 9 | 6 4 3 | 5 7 1 
 5 - 3 | 2 - 1 | - - -      5 7 3 | 2 9 1 | 6 8 4 
 1 - 4 | - - - | - - -      1 6 4 | 8 7 5 | 2 9 3 
```

#### Solving all sudoku puzzles in a text file:
```
$ ./norvigsudoku <TXT file containing puzzles>

Or alternatively:
$ nim c -r norvigsudoku.nim <TXT file containing puzzles>

e.g.
$ ./norvigsudoku top95.txt
```
* See `top95.txt` and `p096_sudoku.txt` for example file formats
* To save the output to a file, simply do an output redirection as such:
```
$ ./norvigsudoku top95.txt > solved_top95.txt
```

## mysolver.nim
My second sudoku solver based on Computerphile's sudoku solver:
https://www.youtube.com/watch?v=G_UYXzGuqvM

To run, simply compile the program with the `c -r` flags:
```
$ nim c -r mysolver.nim
```
To edit the puzzle, simply edit the source and modify the `INITIAL_GRID` variable.
The main difference between this solver and computerphile's is that this uses an iterative approach using stacks and allows returning of all potential solutions to a sudoku puzzle as a sequence/list. Unfortunately, it can be slow depending on how and where the blank cells are so it's best to compile this with the `-d:release` parameter. Example:
```
$ nim c -r -d:release mysolver.nim
```
## mysolver.py
The pre-cursor to `mysolver.nim`, but written in Python. Running and editing this involves the same concepts as the above. e.g. To run, enter in the terminal:
```
$ python3 mysolver.py
```
## computerphile.py
The script adapted from the computerphile video. It is my first ever sudoku solver `:-)`.
