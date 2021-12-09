import os
import math
import strutils
import sequtils

proc `{}`(self: seq[int], i: int): int =
    if i in 0 ..< self.len:
        return self[i]
    return int.high

proc `{}`(self: seq[seq[int]], i: int): seq[int] =
    if i in 0 ..< self.len:
        return self[i]
    return @[]

proc solution(filename: string): int =
    let values = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.mapIt(ord(it) - ord('0')))

    for i in 0 ..< len(values):
        for j in 0 ..< len(values[i]):
            let value = values[i][j]
            if value < values{i - 1}{j} and value < values{i + 1}{j} and value < values{i}{j + 1} and value < values{i}{j - 1}:
                # echo value
                inc result, value + 1

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
