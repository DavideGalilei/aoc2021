import os
import math
import stats
import strutils
import sequtils

func triangular(n: int): int =
    return n * (n + 1) div 2

proc fuel(nums: openarray[int], x: int): int =
    for num in nums:
        inc result, triangular(abs(num - x))


proc solution(filename: string): int =
    let numbers = filename.readFile
        .strip()
        .split(',')
        .map(parseInt)

    let
        mean = stats.mean(numbers)
        floor = toInt(floor(mean))
        ceil = toInt(ceil(mean))

    return min(
        numbers.fuel(floor),
        numbers.fuel(ceil)
    )

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
