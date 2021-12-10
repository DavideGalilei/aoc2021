import os
import sets
import tables
import strutils
import sequtils

const space = {
    0: 6, 1: 2,
    2: 5, 3: 5,
    4: 4, 5: 5,
    6: 6, 7: 3,
    8: 7, 9: 6,
}.toTable()

const digits = [
    space[1],
    space[4],
    space[7],
    space[8],
]

proc solution(filename: string): int =
    let values = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.split("|"))
        .mapIt(@[
            it[0].strip().splitWhitespace(),
            it[1].strip().splitWhitespace()])

    # 1, 4, 7, 8
    for value in values:
        for digit in value[1]:
            if len(digit.toHashSet()) in digits:
                inc result

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
