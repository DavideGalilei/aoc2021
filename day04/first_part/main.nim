import os
import math
import strutils
import sequtils

type
    Bingo = object
        rows: seq[seq[int]]

proc won(self: Bingo): bool =
    for row in self.rows: # Row streak
        if row.sum == -5:
            return true

    for i in 0 .. 4: # Column streak
        if self.rows.mapIt(it[i]).sum == -5:
            return true

proc markNumber(self: var Bingo, number: int) =
    for i in 0 ..< len(self.rows):
        for j in 0 ..< len(self.rows[i]):
            if self.rows[i][j] == number:
                self.rows[i][j] = -1

template sumUnmarked(self: Bingo): int =
    self.rows.mapIt(it.filterIt(it != -1).sum).sum

proc solution(filename: string): int =
    let f = open(filename, fmRead)
    defer: f.close()

    let numbers = f.readLine().split(',').map(parseInt)
    
    var
        tables: seq[Bingo]
        current: Bingo

    while not f.endOfFile:
        let l = f.readLine()
    
        if l != "": current.rows.add(l.splitWhitespace().map(parseInt))
        if current.rows.len() == 5:
            tables.add(current)
            reset current

    for number in numbers:
        for i in 0 ..< len(tables):
            tables[i].markNumber(number)
            if tables[i].won():
                return number * tables[i].sumUnmarked


when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
