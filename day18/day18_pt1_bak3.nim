include ../parser

proc getLeftmostNode(self: Node): Node =
    var self = self
    while not self.parent.isNil and self.parent.left.kind != nkLiteral:
        self.parent = self.parent.parent
    if self.left.isNil or self.left.kind == nkList:
        return nil
    return self.left

proc getRightmostNode(self: Node): Node =
    var self = self
    while not self.parent.isNil and self.parent.right.kind != nkLiteral:
        self.parent = self.parent.parent
    if self.right.isNil or self.right.kind == nkList:
        return nil
    return self.right

proc getDeepestNode(self: Node): Node =
    var left, right: Node

    if not self.right.isNil and self.right.kind != nkLiteral:
        right = getDeepestNode(self.right)

    if not self.left.isNil and self.left.kind != nkLiteral:
        left = getDeepestNode(self.left)
    
    if left.isNil and right.isNil: return self
    if left.isNil: return right
    if right.isNil: return left
    if right.depth > left.depth:
        return right.parent
    return left.parent

proc explodeOnce(self: Node) =
    var node = getDeepestNode(self)
    
    let (leftMost, rightMost) = (
        getLeftmostNode(node),
        getRightmostNode(node),
    )
    # echo "LEFTMOST ------------\n", debug leftMost
    # echo "RIGHTMOST ------------\n", debug leftMost
    # let isLeft = node.parent.left != nil and node.parent.left == node
    # if isLeft:
    if leftMost != nil:
        leftMost.value += node.left.value
    
    if rightMost != nil:
        rightMost.value += node.right.value
    
    

    
proc solution(filename: string): int =
    var nodes: seq[Node]
    for line in filename.lines:
        nodes.add(line.parse())

    var current: Node = nodes[0]
    nodes.delete(0)

    current.explodeOnce()
    echo debug current

    # echo debug current.getDeepestNode()
    # echo current.getLeftmostInteger()
    # echo debug current

    #[echo current, getNestingLevel(current)
    if getNestingLevel(current) >= 4:
        current = current.reduce()

    for node in nodes:
        if getNestingLevel(current) >= 4:
            current = current.reduce()
        current = current + node]#

    # echo debug nodes[0]
    # echo debug parse("[1, 2]") + parse("[[3, 4], 5]")
    # echo getNestingLevel(parse("[[[0]]]"))

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
