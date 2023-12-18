import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue


struct Day18: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	struct Point: Hashable, Equatable {
		var x: Int
		var y: Int
		
		func movingIn(direction: Direction, distance: Int = 1) -> Point {
			switch direction {
			case .up: return Point(x: x, y: y - distance)
			case .down: return Point(x: x, y: y + distance)
			case .right: return Point(x: x + distance, y: y)
			case .left: return Point(x: x - distance, y: y)
			}
		}
		
		var cgPoint: CGPoint {
			CGPoint(x: x, y: y)
		}
	}
	
	enum Direction: String, Hashable {
		case up = "U"
		case down = "D"
		case right = "L"
		case left = "R"
		
		var opposite: Direction {
			switch self {
				case .up: return .down
				case .down: return .up
				case .right: return .left
				case .left: return .right
			}
		}
	}
	
	struct Instruction {
		var direction: Direction
		var distance: Int
		var color: String
		
		init?(from string: String) {
			guard let (_, dirString, distString, colorString) = string.firstMatch(of: /(U|D|R|L) (\d+) \(\#(\w{6})\)/)?.output as? (Substring, Substring, Substring, Substring),
				let direction = Direction(rawValue: String(dirString)),
				let distance = Int(distString) else { return nil }
			self.direction = direction
			self.distance = distance
			self.color = String(colorString)
		}
		
		var string: String {
			"\(direction.rawValue) \(distance) (#\(color))"
		}
	}
	
	func part1() async -> Any {
		let instructions = data.components(separatedBy: .newlines).compactMap(Instruction.init(from:))
		assert(instructions.map(\.string).joined(separator: "\n") == data)
		
		let start = Point(x: 0, y: 0)
		var location = start
		
		var points = [start]
		var perimeter = 0
		
		for instruction in instructions {
			location = location.movingIn(direction: instruction.direction, distance: instruction.distance)
			points.append(location)
			perimeter += instruction.distance
		}
		
		let determinants = points.adjacentPairs().map({ (first, second) in first.x * second.y - first.y * second.x })
		let shoestring = abs(determinants.sum() / 2)
		let picksTheorem = shoestring + perimeter / 2 + 1
		return picksTheorem
	}
	
	func part2() async -> Any {
		let instructions = data.components(separatedBy: .newlines).compactMap(Instruction.init(from:))
		assert(instructions.map(\.string).joined(separator: "\n") == data)
		
		let start = Point(x: 0, y: 0)
		var location = start
		
		var points = [start]
		var perimeter = 0
		
		for instruction in instructions {
			var direction: Direction
			switch instruction.color.last {
				case "0": direction = .right
				case "1": direction = .down
				case "2": direction = .left
				case "3": direction = .up
				default: fatalError()
			}
			var color = instruction.color.dropLast()
			color.insert("0", at: color.startIndex)
			let pairs = color.chunks(ofCount: 2).compactMap({ UInt8($0, radix: 16) }).map({ Int($0) })
			let distance = (pairs[0] << 16) | (pairs[1] << 8) | pairs[2]
			
			location = location.movingIn(direction: direction, distance: distance)
			points.append(location)
			perimeter += distance
		}
		
		let determinants = points.adjacentPairs().map({ (first, second) in first.x * second.y - first.y * second.x })
		let shoestring = abs(determinants.sum() / 2)
		let picksTheorem = shoestring + perimeter / 2 + 1
		return picksTheorem
	}
}
