import os, strutils

proc solution(filename: string): int =
    var last: int
    for line in filename.lines:
        if line.strip() != "":
            let parsed = parseInt(line)
            if parsed > last:
                inc result
            last = parsed
    dec result

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
