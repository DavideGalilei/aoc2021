import os, strutils

proc solution(filename: string): int =
    var
        position: int
        depth: int
        
    for line in filename.lines:
        if line.strip() != "":
            var splitted = line.split()
            let
                op = splitted[0]
                num = parseInt(splitted[1])

            case op:
            of "up":
                depth -= num
            of "down":
                depth += num
            of "forward":
                position += num

    return position * depth

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
