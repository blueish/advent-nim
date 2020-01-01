import unittest
import graphs

suite "run graphs":
  test "simple graph":
    var
      graph = BuildGraph("tests/data/simple.graph")
      count = OrbitCount(graph)

    check(count == 42)

  test "simple graph":
    var
      graph = BuildGraph("tests/data/day6.graph")
      count = OrbitCount(graph)

    check(count == 292387)

  test "distance between day6":
    var
      graph = BuildGraph("tests/data/day6.graph")
      count = DistanceBetweenOrbiting(graph, "YOU", "SAN")

    check(count == 433)

