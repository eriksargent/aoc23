import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day14: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	enum Position {
		case fixed
		case empty
		case rock
		
		var char: Character {
			switch self {
			case .fixed:
				return "#"
			case .empty:
				return "."
			case .rock:
				return "O"
			}
		}
		
		init?(from char: Character) {
			switch char {
			case "#":
				self = .fixed
			case ".":
				self = .empty
			case "O":
				self = .rock
			default:
				return nil
			}
		}
	}
	
	func shiftNorth(lines: inout[[Position]]) -> Int {
		var load = 0
		let height = lines.count
		for (index, line) in lines.enumerated() {
			for (rockIndex, _) in line.enumerated().filter({ $0.element == .rock }) {
				var shift = false
				var shiftedIndex = index - 1
				while shiftedIndex >= 0 && lines[shiftedIndex][rockIndex] == .empty {
					shiftedIndex -= 1
					shift = true
				}
				load += height - (shiftedIndex + 1)
				if shift {
					shiftedIndex += 1
					lines[shiftedIndex][rockIndex] = .rock
					lines[index][rockIndex] = .empty
				}
			}
		}
		
		return load
	}
	
	func shiftEast(lines: inout[[Position]]) -> Int {
		var load = 0
		let height = lines.count
		for (index, line) in lines.enumerated() {
			for (rockIndex, _) in line.enumerated().reversed().filter({ $0.element == .rock }) {
				var shift = false
				var shiftedIndex = rockIndex + 1
				while shiftedIndex < line.count && lines[index][shiftedIndex] == .empty {
					shiftedIndex += 1
					shift = true
				}
				load += height - index
				if shift {
					shiftedIndex -= 1
					lines[index][shiftedIndex] = .rock
					lines[index][rockIndex] = .empty
				}
			}
		}
		
		return load
	}
	
	func shiftSouth(lines: inout[[Position]]) -> Int {
		var load = 0
		let height = lines.count
		for (index, line) in lines.enumerated().reversed() {
			for (rockIndex, _) in line.enumerated().filter({ $0.element == .rock }) {
				var shift = false
				var shiftedIndex = index + 1
				while shiftedIndex < height && lines[shiftedIndex][rockIndex] == .empty {
					shiftedIndex += 1
					shift = true
				}
				load += height - (shiftedIndex - 1)
				if shift {
					shiftedIndex -= 1
					lines[shiftedIndex][rockIndex] = .rock
					lines[index][rockIndex] = .empty
				}
			}
		}
		
		return load
	}
	
	func shiftWest(lines: inout[[Position]]) -> Int {
		var load = 0
		let height = lines.count
		for (index, line) in lines.enumerated() {
			for (rockIndex, _) in line.enumerated().filter({ $0.element == .rock }) {
				var shift = false
				var shiftedIndex = rockIndex - 1
				while shiftedIndex >= 0 && lines[index][shiftedIndex] == .empty {
					shiftedIndex -= 1
					shift = true
				}
				load += height - index
				if shift {
					shiftedIndex += 1
					lines[index][shiftedIndex] = .rock
					lines[index][rockIndex] = .empty
				}
			}
		}
		
		return load
	}
	
	func part1() async -> Any {
		var lines = data.components(separatedBy: .newlines).map({ $0.compactMap(Position.init(from:)) })
		assert(lines.map({ String($0.map(\.char)) }).joined(separator: "\n") == data)
		
		let load = shiftNorth(lines: &lines)
		
		print(lines.map({ String($0.map(\.char)) }).joined(separator: "\n"))
		
		return load
	}
	
	func part2() async -> Any {
		var lines = data.components(separatedBy: .newlines).map({ $0.compactMap(Position.init(from:)) })
		assert(lines.map({ String($0.map(\.char)) }).joined(separator: "\n") == data)
		
		let testSamples = 500
		// Only do 100 cycles, should have a stable pattern at that point
		let pattern = (0..<testSamples).map({ _ in
			_ = shiftNorth(lines: &lines)
			_ = shiftWest(lines: &lines)
			_ = shiftSouth(lines: &lines)
			let load = shiftEast(lines: &lines)
			return load
		})
		print(pattern)
		
		guard let lastItem = pattern.last, let lastIndex = pattern.dropLast().lastIndex(of: lastItem) else { return 0 }
		let cycleLength = pattern.count - lastIndex - 1
		let repetitions = (1000000000 - testSamples) % cycleLength
		let load = pattern[lastIndex + repetitions]
		return load
	}
}
