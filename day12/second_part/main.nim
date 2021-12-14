import os
import sets
import tables
import deques
import strutils
import sequtils

# https://www.reddit.com/r/adventofcode/comments/rehj2r/comment/ho9qiw0/?utm_source=share&utm_medium=web2x&context=3

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0


func isSmall(cave: string): bool =
    return cave[0].isLowerAscii()

proc getPaths(maze: var Table[string, seq[string]], start, goal: string, twice: bool): int =
    var deque: Deque[tuple[
        start: string,
        smallCaves: HashSet[string],
        twice: bool]]
    deque.push((start: start, smallCaves: initHashSet[string](), twice: twice))

    while not deque.empty:
        var (current, small, twice) = deque.pop()
        if current == goal:
            inc result
        elif current.isSmall:
            twice = twice and (current notin small)
            small.incl(current)
        for node in maze.getOrDefault(current, newSeq[string]()):
            if node notin small or twice:
                let smallCopy = small
                deque.push((start: node, smallCaves: smallCopy, twice: twice))


proc solution(filename: string, revisitSmall: bool = false): int =
    let values = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.split('-'))
    
    var maze: Table[string, seq[string]]

    for value in values:
        let (startCave, endCave) = (value[0], value[1])
        if startCave != "end" and endCave != "start":
            discard maze.hasKeyOrPut(startCave, newSeq[string]())
            maze[startCave].add(endCave)
        if endCave != "end" and startCave != "start":
            discard maze.hasKeyOrPut(endCave, newSeq[string]())
            maze[endCave].add(startCave)
    
    return maze.getPaths("start", "end", twice = true)


when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
