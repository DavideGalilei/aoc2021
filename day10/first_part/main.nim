import os
import math
import tables
import deques
import sequtils

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0


const closing = ")]}>"
const points = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137,
}.toTable()

const matches = {
    ')': '(',
    ']': '[',
    '}': '{',
    '>': '<',
}.toTable()


proc solution(filename: string): int =
    let values = filename.lines
        .toSeq()
        .filterIt(it != "")

    for brackets in values:
        var stack = initDeque[char]()
        
        for bracket in brackets:
            # echo stack
            if bracket in closing:
                if matches[bracket] != stack.pop():
                    # Corrupted
                    inc result, points[bracket]
                    break
            else:
                stack.push(bracket)
            if stack.empty:
                # Incomplete
                break


when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
