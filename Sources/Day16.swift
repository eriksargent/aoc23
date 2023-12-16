import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day16: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	struct Point: Hashable {
		var x: Int
		var y: Int
		
		func movementHash(from direction: Direction, option: Option) -> Int {
			var hasher = Hasher()
			hasher.combine(self)
			hasher.combine(direction)
			hasher.combine(option)
			return hasher.finalize()
		}
		
		static var zero: Point { Point(x: 0, y: 0) }
	}
	
	enum Direction: Hashable {
		case up
		case down
		case right
		case left
		
		var opposite: Direction {
			switch self {
			case .up: return .down
			case .down: return .up
			case .right: return .left
			case .left: return .right
			}
		}
		
		func move(point: Point) -> Point {
			switch self {
			case .up: return Point(x: point.x, y: point.y - 1)
			case .down: return Point(x: point.x, y: point.y + 1)
			case .right: return Point(x: point.x + 1, y: point.y)
			case .left: return Point(x: point.x - 1, y: point.y)
			}
		}
	}
	
	enum Option: Character {
		case empty = "."
		case lmirror = "/"
		case rmirror = "\\"
		case vertsplitter = "|"
		case horizsplitter = "-"
		
		func redirect(from: Direction) -> [Direction] {
			switch self {
			case .empty: return [from]
			case .lmirror:
				switch from {
				case .up: return [.right]
				case .down: return [.left]
				case .right: return [.up]
				case .left: return [.down]
				}
			case .rmirror:
				switch from {
				case .up: return [.left]
				case .down: return [.right]
				case .right: return [.down]
				case .left: return [.up]
				}
			case .vertsplitter:
				switch from {
				case .up, .down: return [from]
				case .right, .left: return [.down, .up]
				}
			case .horizsplitter:
				switch from {
				case .up, .down: return [.right, .left]
				case .right, .left: return [from]
				}
			}
		}
	}

	func getEnergized(from grid: [[Option]], starting: Point, direction: Direction) -> Int {
		guard let width = grid.first?.count else { return 0 }
		let height = grid.count
		
		let startingOptions = grid[starting.y][starting.x].redirect(from: direction)
		var queue: [(Point, Direction)] = startingOptions.map({ (starting, $0) })
		var visited = Set<Int>([starting.movementHash(from: direction, option: grid[0][0])])
		var energized = Set<Point>([starting])
		
		while let (next, direction) = queue.popFirst() {
			let point = direction.move(point: next)
			guard point.x >= 0 && point.x < width && point.y >= 0 && point.y < height else { continue }
			
			let option = grid[point.y][point.x]
			let hash = point.movementHash(from: direction, option: option)
			if !visited.contains(hash) {
				let options = option.redirect(from: direction)
				queue.append(contentsOf: options.map({ (point, $0) }))
				visited.insert(hash)
				energized.insert(point)
			}
		}
		
		return energized.count
	}
	
	func part1() async -> Any {
		let grid = data.components(separatedBy: .newlines).map({ $0.compactMap(Option.init(rawValue:)) })
		let formatted = grid.map({ String($0.map(\.rawValue)) }).joined(separator: "\n")
		assert(formatted == data)
		
		let start = Point.zero
		return getEnergized(from: grid, starting: start, direction: .right)
	}
	
	func part2() async -> Any {
		let grid = data.components(separatedBy: .newlines).map({ $0.compactMap(Option.init(rawValue:)) })
		let formatted = grid.map({ String($0.map(\.rawValue)) }).joined(separator: "\n")
		assert(formatted == data)
		
		guard let width = grid.first?.count else { return 0 }
		let height = grid.count
		
		return await withTaskGroup(of: Int.self, returning: Int.self) { group in
			group.addTask {
				(0..<height).map({ y in getEnergized(from: grid, starting: Point(x: 0, y: y), direction: .right) }).max() ?? 0
			}
			group.addTask {
				(0..<height).map({ y in getEnergized(from: grid, starting: Point(x: width - 1, y: y), direction: .left) }).max() ?? 0
			}
			
			group.addTask {
				(0..<width).map({ x in getEnergized(from: grid, starting: Point(x: x, y: 0), direction: .down) }).max() ?? 0
			}
			group.addTask {
				(0..<width).map({ x in getEnergized(from: grid, starting: Point(x: x, y: height - 1), direction: .up) }).max() ?? 0
			}
			
			var energy = 0
			for await result in group {
				energy = max(energy, result)
			}
			return energy
		}
	}
}


extension Array {
	mutating func popFirst() -> Element? {
		guard !isEmpty else { return nil }
		return removeFirst()
	}
}
