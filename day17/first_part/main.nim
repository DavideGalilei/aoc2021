import os
import strutils
import sequtils

type Coord = object
    x, y: int

proc parsePoint(source: string): seq[int] =
    return source.split('=')[1].split("..").map(parseInt)

proc solution(filename: string): int =
    let
        positions = filename.readFile.splitWhitespace()[^2..^1].join().split(',').map(parsePoint)
        startPos = Coord(x: positions[0][0], y: positions[1][0])

    return (not startPos.y) * -startPos.y div 2

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
