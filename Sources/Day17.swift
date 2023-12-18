import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue


struct Day17: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	struct Point: Hashable, Equatable {
		var x: Int
		var y: Int
		
		static var zero: Point { Point(x: 0, y: 0) }
		
		func manhattanDistance(to other: Point) -> Int {
			abs(x - other.x) + abs(y - other.y)
		}
		
		func movingIn(direction: Direction) -> Point {
			switch direction {
				case .up: return Point(x: x, y: y - 1)
				case .down: return Point(x: x, y: y + 1)
				case .right: return Point(x: x + 1, y: y)
				case .left: return Point(x: x - 1, y: y)
			}
		}
	}
	
	enum Direction: Hashable {
		case up
		case down
		case right
		case left
		
		var string: String {
			switch self {
				case .up: return "U"
				case .down: return "D"
				case .right: return "R"
				case .left: return "L"
			}
		}
		
		static func dir(from: Character) -> Direction? {
			switch from {
				case "U": return .up
				case "D": return .down
				case "R": return .right
				case "L": return .left
				default: return nil
			}
		}
		
		var opposite: Direction {
			switch self {
				case .up: return .down
				case .down: return .up
				case .right: return .left
				case .left: return .right
			}
		}
	}
	
	struct State: Comparable, CustomDebugStringConvertible, Hashable {
		var point: Point
		var heatLoss: Int
		var direction: Direction
		var streak: Int
		var heuristic: Int
		
		static func < (lhs: Self, rhs: Self) -> Bool {
			lhs.heatLoss + lhs.heuristic < rhs.heatLoss + rhs.heuristic
		}
		
		var debugDescription: String {
			"State(\(point), \(direction), \(streak), \(heatLoss)"
		}
	}
	
	func search(input: String, minBeforeTurn: Int, maxWithoutTurn: Int) -> Int {
		let grid = data.components(separatedBy: .newlines).map({ $0.map(String.init).compactMap(Int.init) })
		assert(grid.map({ $0.map(String.init).joined() }).joined(separator: "\n") == data)
		
		let width = grid[0].count
		let height = grid.count
		let goal = Point(x: width - 1, y: height - 1)
		
		var queue = PriorityQueue<State>(ascending: true, startingValues: [
			State(
				point: Point.zero,
				heatLoss: 0,
				direction: .right,
				streak: 0,
				heuristic: Point.zero.manhattanDistance(to: goal)),
			State(
				point: Point.zero,
				heatLoss: 0,
				direction: .down,
				streak: 0,
				heuristic: Point.zero.manhattanDistance(to: goal)),
		])
		
		var visited = Set<String>()
		while let next = queue.pop() {
			if next.point == goal {
				if next.streak < minBeforeTurn {
					continue
				}
				
				return next.heatLoss
			}
			
			let point = next.point
			let key = "\(point.x)-\(point.y)-\(next.direction.string)-\(next.streak)"
			if visited.contains(key) {
				continue
			}
			visited.insert(key)
			
			let neighbors = [
				(Point(x: point.x + 1, y: point.y), Direction.right),
				(Point(x: point.x - 1, y: point.y), Direction.left),
				(Point(x: point.x, y: point.y + 1), Direction.down),
				(Point(x: point.x, y: point.y - 1), Direction.up),
			]
				.filter { $0.0.x >= 0 && $0.0.x < width && $0.0.y >= 0 && $0.0.y < height }
				.filter { $0.1 != next.direction.opposite }
				.map { ($0.0, $0.1, $0.1 == next.direction ? next.streak + 1 : 1) }
				.filter { $0.2 <= maxWithoutTurn && (next.streak >= minBeforeTurn || $0.1 == next.direction) }
			
			for (newPoint, newDirection, newStreak) in neighbors {
				let newCost = next.heatLoss + grid[newPoint.y][newPoint.x]
				queue.push(
					State(
						point: newPoint,
						heatLoss: newCost,
						direction: newDirection,
						streak: newStreak,
						heuristic: newPoint.manhattanDistance(to: goal)))
			}
		}
		
		return 0
	}
	
	func part1() async -> Any {
		search(input: data, minBeforeTurn: 0, maxWithoutTurn: 3)
	}
	
	func part2() async -> Any {
		search(input: data, minBeforeTurn: 4, maxWithoutTurn: 10)
	}
}
