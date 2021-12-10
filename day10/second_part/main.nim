import os
import math
import tables
import deques
import sequtils
import algorithm

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0


const closing = ")]}>"
const points = {
    '(': 1,
    '[': 2,
    '{': 3,
    '<': 4,
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

    var scores: seq[int]

    for brackets in values:
        var stack = initDeque[char]()
        var opened, score: int

        block uncorrupted:
            for bracket in brackets:
                # echo stack
                if bracket in closing:
                    if not stack.empty and matches[bracket] != stack.pop():
                        # Corrupted
                        break uncorrupted
                    dec opened
                else:
                    inc opened
                    stack.push(bracket)

            while not stack.empty:
                score *= 5
                inc score, points[stack.pop()]
            
            scores.add(score)

    # Get middle element from an odd seq
    return sorted(scores)[scores.len div 2]


when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
