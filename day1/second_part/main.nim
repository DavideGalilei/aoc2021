import os, strutils, sequtils

proc solution(filename: string): int =
    var last: int
    let numbers = filename.lines
        .toSeq()
        .filterIt(it.strip() != "")
        .map(parseInt)
    
    for i in 1 ..< numbers.len - 2:
        let elem = numbers[i ..< i + 3].foldl(a + b) # sum
        if elem > last:
            inc result
        last = elem

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
