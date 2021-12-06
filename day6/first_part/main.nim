import os
import strutils
import sequtils

proc solution(filename: string, days: int = 80): int =
    var numbers = filename.readFile
        .strip()
        .split(',')
        .map(parseInt)

    # echo numbers
    for i in 0 ..< days:
        for num in 0 ..< len(numbers):
            if numbers[num] == 0:
                numbers.add(8)
            numbers[num] = if numbers[num] == 0: 6
                else: numbers[num] - 1
        # echo numbers

    return len(numbers)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
