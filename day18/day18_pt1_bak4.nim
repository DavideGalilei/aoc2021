import os
import tables
import deques
import streams
import strutils
import sequtils

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0
template rollback*(self: StringStream, offset: int) = self.setPosition(self.getPosition() - offset)

type
    NodeKind = enum
        nkLiteral, nkList

    Node = ref object
        case kind: NodeKind
        of nkLiteral:
            value: int
        of nkList:
            children: seq[Node]

import json
proc debug(node: Node): string =
    return pretty %*(node)

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

proc getNestingLevelImpl(self: Node): int =
    if self.kind == nkLiteral: return 0
    var depths: seq[int]
    for child in self.children:
        depths.add(1 + getNestingLevelImpl(child))
    return max(depths)

proc getNestingLevel(self: Node): int = getNestingLevelImpl(self) - 1

proc addLeft(self, other: Node): Node =
    echo "ADD LEFT", debug self, debug other
    if other.isNil:
        return self
    if self.kind == nkLiteral:
        return Node(kind: nkLiteral, value: self.value + other.value)
    return Node(
        kind: nkList,
        children: @[
            self.children[0].addLeft(other),
            self.children[1],
        ]
    )

proc addRight(self, other: Node): Node =
    echo "ADD RIGHT", debug self, debug other
    if other.isNil:
        return self
    if self.kind == nkLiteral:
        return Node(kind: nkLiteral, value: self.value + other.value)
    return Node(
        kind: nkList,
        children: @[
            self.children[0],
            self.children[1].addRight(other),
        ]
    )

proc explodePair(self: Node, layer: int = 0): (bool, Node, Node, Node) =
    # echo debug(self), " ", layer

    if self.kind == nkLiteral:
        return (false, self, Node(), Node())
    
    # echo debug self
    let
        left = self.children[0]
        right = self.children[1]
    
    if layer == 4:
        return (true, Node(), left, right)
    
    var (exploded, next, l, r) = explodePair(left, layer + 1)
    if exploded:
        return (true, Node(kind: nkList, children: @[next, right.addLeft(r)]), l, Node())

    (exploded, next, l, r) = explodePair(right, layer + 1)
    if exploded:
        return (true, Node(kind: nkList, children: @[left.addRight(l), next]), Node(), r)

    return (false, self, Node(), Node())

proc copy(self: Node): Node =
    result = deepCopy(self)

var c: int
proc splitNum(self: Node): Node =
    echo "SPLITTT ", debug self
    inc c
    if c > 20: return
    if self.kind == nkLiteral:
        echo "LIT"
        if self.value > 9:
            return Node(kind: nkList, children: @[
                Node(kind: nkLiteral, value: self.value div 2),
                Node(kind: nkLiteral, value: self.value div 2 + (self.value and 1)),
            ])
        return self
    let
        l: Node = self.children[0]
        r: Node = self.children[1]
    echo "LEFT: ", debug l
    echo "RIGHT: ", debug r
    echo "\n\n"

    let left = splitNum(l)
    echo "DIFFERENTLEFTTTT ", debug left
    # if left.isNil: return self
    if left != l:
        echo "DIFFERENT"
        return Node(kind: nkList, children: @[left, r])
    return Node(kind: nkList, children: @[l, splitNum(r)])

proc `+`(self, other: Node): Node =
    result = Node(kind: nkList, children: @[self, other])
    while true:
        let explodedResult = explodePair(result)
        let exploded = explodedResult[0]
        result = explodedResult[1]
        if not exploded:
            let prev = result
            result = splitNum(result)
            if result == prev:
                return result

proc magnitude(self: Node): int =
    if self.kind == nkLiteral:
        return self.value
    return 3 * magnitude(self.children[0]) + 2 * magnitude(self.children[1])

proc solution(filename: string): int =
    var nodes: seq[Node]
    
    for line in filename.lines:
        let parsed = line.parse()
        # echo debug parsed
        nodes.add(parsed)
    # return
    var current: Node = nodes[0]
    nodes.delete(0)

    for snail in nodes:
        current = current + snail
    
    echo debug current

    return magnitude(current)

    # echo debug current, getNestingLevel(current)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
