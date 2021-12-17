import os
import math
import strutils
import sequtils

type Coord = object
    x, y: int

proc parsePoint(source: string): seq[int] =
    return source.split('=')[1].split("..").map(parseInt)

func run(x, y: int, startPos, endPos: Coord): int =
    var (x, y) = (x, y)
    var posX, posY: int
    while posX <= endPos.x and posY >= startPos.y:
        inc posX, x
        inc posY, y
        if x > 0:
            dec x
        dec y

        if posX >= startPos.x and posX <= endPos.x and posY >= startPos.y and posY <= endPos.y:
            return 1

# https://www.reddit.com/r/adventofcode/comments/ri9kdq/comment/hoxegsx/?utm_source=share&utm_medium=web2x&context=3
# I didn't really want to bruteforce, so I looked up for solutions
# and I found this one which uses just math, making it efficient

proc solution(filename: string): int =
    let
        positions = filename.readFile.splitWhitespace()[^2..^1].join().split(',').map(parsePoint)
        startPos = Coord(x: positions[0][0], y: positions[1][0])
        endPos = Coord(x: positions[0][1], y: positions[1][1])

    var (maxX, maxY, minX, minY) = (
        endPos.x,
        (abs startPos.y) - 1,
        int(ceil(sqrt(1 + float(8 * startPos.x)) / 2 - 1)),
        startPos.y,
    )

    for x in minX .. maxX:
        for y in minY .. maxY:
            inc result, run(x, y, startPos, endPos)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
