import os
import tables
import strutils
import sequtils
import algorithm

proc median[T: int](data: openarray[T]): T =
    var data = sorted(data)
    let n = len(data)
    if n == 0:
        return 0
    if n mod 2 == 1:
        return data[n div 2]
    else:
        let i = n div 2
        return (data[i - 1] + data[i]) div 2

proc solution(filename: string): int =
    let numbers = filename.readFile
        .strip()
        .split(',')
        .map(parseInt)

    let common = median(numbers)

    for num in numbers:
        inc result, abs(num - common)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
