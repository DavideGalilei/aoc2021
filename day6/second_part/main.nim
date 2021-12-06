import os
import math
import strutils
import sequtils

proc solution(filename: string, days: int = 256): int =
    var numbers = filename.readFile
        .strip()
        .split(',')
        .map(parseInt)

    var week: seq[int] = newSeq[int](9)

    for fish in numbers:
        inc week[fish]

    for day in 0 ..< days:
        inc week[(day + 7) mod 9], week[day mod 9]

    return sum(week)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
