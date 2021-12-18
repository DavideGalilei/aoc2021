###############################
#                             #
#   Included in other files   #
#                             #
###############################

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
            left: Node
            right: Node
        parent: Node
        depth: int

proc parseNumber(stream: StringStream): int =
    var isNeg: bool
    while not stream.atEnd and (let c = stream.readChar(); c.isDigit or c == '-'):
        if c == '-':
            isNeg = true
        else:
            result *= 10
            result += ord(c) - ord('0')
    stream.rollback(1)
    if isNeg: result = -result

proc parse(line: string): Node =
    result = Node(kind: nkList)

    let stream = newStringStream(line)
    var stack: Deque[Node]
    stack.push(result)

    while not stream.atEnd():
        let c = stream.readChar()
        # echo c
        if c == '[':
            let n = (Node(kind: nkList, parent: stack[^1], depth: len(stack)))
            # TODO: change parent: nil to parent: stack[^1]

            if stack[^1].left.isNil:
                stack[^1].left = n
            else:
                stack[^1].right = n
            stack.push(n)
        elif c == ']':
            let node = stack.pop()
            stack[^1].right = node
        elif c.isDigit or c == '-':
            stream.rollback(1)
            let n = Node(kind: nkLiteral, value: stream.parseNumber())

            if stack[^1].left.isNil:
                stack[^1].left = n
            else:
                stack[^1].right = n

    return stack.pop().left

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
            left: self,
            right: other,
        )

#[proc getNestingLevelImpl(self: Node): int =
    if self.kind == nkLiteral: return 0
    var depths: seq[int]
    for child in self.children:
        depths.add(1 + getNestingLevelImpl(child))
    return max(depths)

proc getNestingLevel(self: Node): int = getNestingLevelImpl(self) - 1

proc reduce(self: Node): Node =
    var stack: Deque[Node]
    stack.push(self)

    let nesting = getNestingLevel(self)
    
    while len(stack) != nesting:
        if stack[^1].kind != nkLiteral:
            for child in stack.pop().children:
                stack.push(child)
    echo stack]#

import json
proc debug(node: Node): string =
    ## WARNING, do not use if node.parent != nil
    return pretty %*(node)

when isMainModule:
    discard # echo debug parse(currentSourcePath().parentDir / "input.txt")
