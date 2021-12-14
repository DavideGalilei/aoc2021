import os
import tables
import strutils
import sequtils

proc solution(filename: string, times: int = 10): int =
    let f: File = open(filename)
    defer: f.close()
    var templ: seq[char] = f.readLine().strip().toSeq()

    var elements: Table[string, char]

    while not f.endOfFile:
        let line = f.readLine()
        if line == "": continue
        let pair = line.strip().split(" -> ")
        elements[pair[0]] = pair[1][0]
    
    # echo templ
    # echo elements

    for i in 0 ..< times:
        var pos: int
        while pos < templ.len - 1:
            let pair = templ[pos .. min(pos + 1, templ.len)].join()
            if pair in elements:
                inc pos
                templ.insert(elements[pair], pos)
            inc pos
        
        # echo "step ", i + 1, ": ", templ.join()
    let count = templ.toCountTable()
    return count.largest()[1] - count.smallest()[1]

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
