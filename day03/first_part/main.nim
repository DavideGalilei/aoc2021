import os, tables, strutils

proc solution(filename: string): int =
    var
        gamma: int
        epsilon: int
        count: seq[CountTable[int]]
        
    for line in filename.lines:
        if line.strip() != "":
            if line.len > count.len:
                count.setLen(line.len)
                # Should happen only once

            var i: int
            for  c in line:
                count[i].inc(
                    ord(c) - ord('0')
                )
                inc i

    for t in count:
        gamma = gamma shl 1
        epsilon = epsilon shl 1
        if t[0] < t[1]:
            gamma = gamma or 1
        else:
            epsilon = epsilon or 1

    return gamma * epsilon

    

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
