import os
import tables
import deques
import streams
import strutils

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0
template rollback*(self: StringStream, offset: int) = self.setPosition(self.getPosition() - offset)

type
    NodeKind = enum
        nkLiteral, nkList

    Node = object
        case kind: NodeKind
        of nkLiteral:
            value: int
        of nkList:
            children: seq[Node]

proc parseNumber(stream: StringStream): int =
    var isNeg: bool
    while not stream.atEnd and (let c = stream.readChar(); c.isDigit or c == '-'):
        if c == '-':
            isNeg = true
        else:
            result *= 10
            result += ord(c) - ord('0')
    if not stream.atEnd: stream.rollback(1)
    if isNeg: result = -result

proc parse(line: string): Node =
    result = Node(kind: nkList)

    let stream = newStringStream(line)
    var stack: Deque[Node]
    stack.push(result)

    while not stream.atEnd():
        let c = stream.readChar()
        if c.isDigit or c == '-':
            stream.rollback(1)
            stack[^1].children.add(Node(kind: nkLiteral, value: stream.parseNumber()))
        elif c == '[':
            stack.push(Node(kind: nkList))
        elif c == ']':
            let node = stack.pop()
            stack[^1].children.add(node)
    
    if '[' notin line:
        return stack.pop().children[0]
    return stack.pop()

proc `+`(self, other: Node): Node =
    var self = self
    if self.kind == nkLiteral:
        return Node(
            kind: nkLiteral,
            value: self.value + other.value
        )
    else:
        return Node(
            kind: nkList,
            children: @[self, other]
        )

proc getNestingLevel(self: Node): int =
    if self.kind == nkLiteral: return 0
    var depths: seq[int]
    for child in self.children:
        depths.add(1 + getNestingLevel(child))
    return max(depths) - 1

proc reduce(self: Node): Node =
    var stack: Deque[Node]
    

import json
proc debug(node: Node): string =
    return pretty %*(node)

proc solution(filename: string): int =
    var nodes: seq[Node]
    for line in filename.lines:
        nodes.add(line.parse())

    var current: Node
    for node in nodes:
        if getNestingLevel(current) >= 4:
            current = current.reduce()
        current = current + node

    # echo debug nodes[0]
    # echo debug parse("[1, 2]") + parse("[[3, 4], 5]")
    # echo parse("1")
    # echo debug parse("1") + parse("3")
    # echo getNestingLevel(parse("[[[0]]]"))

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
