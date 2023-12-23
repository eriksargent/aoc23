import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue

struct Day21: AdventDay {
	var data: String
	var steps = 64
	
	init(data: String) {
		self.data = data
	}
	
	init(data: String, steps: Int) {
		self.data = data
		self.steps = steps
	}
	
	enum Tile: String {
		case start = "S"
		case rock = "#"
		case plot = "."
	}
	
	func part1() async -> Any {
		let grid = data.components(separatedBy: .newlines).map({ line in line.compactMap({ Tile(rawValue: String($0)) }) })
		assert(grid.map({ $0.map(\.rawValue).joined(separator: "") }).joined(separator: "\n") == data)
		
		let width = grid[0].count
		let height = grid.count
		var startX = 0
		var startY = 0
		for y in 0..<height {
			for x in 0..<width {
				if grid[y][x] == .start {
					startX = x
					startY = y
				}
			}
		}
		
		let freeGrid = grid.map({ $0.map({ $0 != .rock }) })
		func hash(_ x: Int, _ y: Int) -> Int {
			return x + y * width * 10
		}
		
		var visited = Set<Int>()
		var queue: [(Int, Int, Int)] = [(startX, startY, 0)]
		var currentSteps = 0
		var sizes = [Int: Int]()
		
		while let next = queue.popFirst() {
			if next.2 != currentSteps {
				sizes[currentSteps] = visited.count
				currentSteps = next.2
				visited.removeAll()
			}
			
			let hash = hash(next.0, next.1)
			guard !visited.contains(hash) else { continue }
			visited.insert(hash)
			
			if next.2 == steps {
				continue
			}
			
			let options = [
				(next.0, next.1 - 1),
				(next.0, next.1 + 1),
				(next.0 - 1, next.1),
				(next.0 + 1, next.1)
			]
				.filter({ $0.0 >= 0 && $0.1 >= 0 && $0.0 < width && $0.1 < height })
				.filter({ freeGrid[$0.1][$0.0] })
			
			for option in options {
				queue.append((option.0, option.1, next.2 + 1))
			}
		}
		
		print(sizes.sorted(by: \.key).map({ "\($0.key), \($0.value)" }).joined(separator: "; "))
		
		return visited.count
	}
	
	func part2() async -> Any {
		return 0
		let grid = data.components(separatedBy: .newlines).map({ line in line.compactMap({ Tile(rawValue: String($0)) }) })
		assert(grid.map({ $0.map(\.rawValue).joined(separator: "") }).joined(separator: "\n") == data)
		
		let width = grid[0].count
		let height = grid.count
		var startX = 0
		var startY = 0
		for y in 0..<height {
			for x in 0..<width {
				if grid[y][x] == .start {
					startX = x
					startY = y
				}
			}
		}
		
		let freeGrid = grid.map({ $0.map({ $0 != .rock }) })
		func hash(_ x: Int, _ y: Int) -> Int {
			var hasher = Hasher()
			hasher.combine(x)
			hasher.combine(y)
			return hasher.finalize()
		}
		
		func modPoint(_ val: Int, _ size: Int) -> Int {
			var mx = val % size
			if mx < 0 {
				mx += size
			}
			return mx % size
		}
		
		var visited = Set<Int>()
		var queue: [(Int, Int, Int)] = [(startX, startY, 0)]
		var currentSteps = 0
		var values = [0]

		let limit = steps % width + width * 2
//		let limit = 3 * width
		while let next = queue.popFirst() {
			if next.2 != currentSteps {
				values.append(visited.count)
				currentSteps = next.2
				visited.removeAll()
			}
			
			let hash = hash(next.0, next.1)
			guard !visited.contains(hash) else { continue }
			visited.insert(hash)
			
			if next.2 == limit {
				continue
			}
			
			let options = [
				(next.0, next.1 - 1),
				(next.0, next.1 + 1),
				(next.0 - 1, next.1),
				(next.0 + 1, next.1)
			]
				.filter({ freeGrid[modPoint($0.1, height)][modPoint($0.0, width)] })
			
			for option in options {
				queue.append((option.0, option.1, next.2 + 1))
			}
		}
		
//		print(sizes.sorted(by: \.key).map({ "\($0.key), \($0.value)" }).joined(separator: "; "))

		let goal = 26501365
		let mod = goal % width
		let div = goal / width
		let c = values[mod]
		let p1 = values[mod + width]
		let p2 = values[mod + width * 2]
		
		let a = (p2 + c - 2 * p1) / 2
		let b = p1 - c - a
		
		return a * div * div + b * div + c
		
//		let goal = 26501365
//		guard var value = values.last else { return 0 }
//		
//		for index in (limit + 1)...goal {
//			let d2 = delta2[index - width - 1]
//			let d1 = delta1[index - width - 1] + d2
//			value += d1
//			delta1.append(d1)
//			delta2.append(d2)
//		}
//		
//		print("value: \(value) at goal: \(steps)")
//		
//		return value
	}
}
