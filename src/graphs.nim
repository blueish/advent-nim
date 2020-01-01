import sequtils, strutils
import tables
import logging

var logger = newConsoleLogger()
addHandler(logger)

type
  Node = ref object of RootObj
    name: string
    orbits: Node

proc `$`*(n: Node): string =
  var
    orbName = if n.orbits == nil: "none" else: n.orbits.name
  return "Node {" & n.name & "}, orbits: [" & orbName & "]"


proc lengthOrbitList(first: Node): int =
  var
    length = 0
    node = first

  while node.orbits != nil:
    node = node.orbits
    length += 1

  return length

proc BuildGraph*(filename: string): Table[string, Node] =
  var
    table = initTable[string, Node]()
    contents = readFile(filename).strip().split('\n').map do (s: string) -> (string, string):
      let content = s.split(')')
      return (content[0], content[1])

  for (center, orbiter) in contents:
    if not table.hasKey(center):
      table[center] = Node(name: center, orbits: nil)

    if not table.hasKey(orbiter):
      table[orbiter] = Node(name: orbiter, orbits: nil)

    table[orbiter].orbits = table[center]

  return table

proc OrbitCount*(graph: Table[string, Node]): int =
  var
    count: int = 0

  for (name, node) in graph.pairs():
    count += lengthOrbitList(node)

  return count

proc DistanceBetweenOrbiting*(graph: Table[string, Node], start: string, finish: string): int =
  ## Returns the distance between the object [start] is orbiting
  ## and the object [finish] is orbiting
  var
    start_path: seq[string] = @[]
    node = graph[start]
    count = 0

  while node.orbits != nil:
    node = node.orbits
    start_path.add(node.name)

  node = graph[finish]

  while node.orbits != nil:
    node = node.orbits
    if node.name in start_path:
      return count + start_path.find(node.name)

    count += 1


  return -1
