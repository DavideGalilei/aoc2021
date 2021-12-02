import os, strutils

proc solution(filename: string): int =
    var
        position: int
        depth: int
        aim: int
        
    for line in filename.lines:
        if line.strip() != "":
            var splitted = line.split()
            let
                op = splitted[0]
                num = parseInt(splitted[1])

            case op:
            of "up":
                aim -= num
            of "down":
                aim += num
            of "forward":
                position += num
                depth += aim * num

    return position * depth

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
