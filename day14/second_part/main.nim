import os
import tables
import sequtils
import strutils

proc solution(filename: string, times: int = 40): int =
    let f: File = open(filename)
    defer: f.close()
    var templ: string = f.readLine().strip()

    var elements: Table[string, char]

    while not f.endOfFile:
        let line = f.readLine()
        if line == "": continue
        let pair = line.strip().split(" -> ")
        elements[pair[0]] = pair[1][0]
    
    var
        pairs: Table[string, int]
        chars: CountTable[char]

    for pair in elements.keys:
        if pair notin pairs:
            pairs[pair] = 0
        inc pairs[pair], templ.count(pair)

    for c in elements.values:
        if c notin chars:
            chars[c] = 0
        chars[c] = templ.count(c)

    # echo elements
    # echo pairs
    # echo chars

    for i in 0 ..< times:
        let copy = pairs.pairs().toSeq()
        for (pair, value) in copy:
            pairs[pair] -= value
            pairs[pair[0] & elements[pair]] += value
            pairs[elements[pair] & pair[1]] += value
            inc chars, elements[pair], value

    # echo chars
    return chars.largest()[1] - chars.smallest()[1]

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
