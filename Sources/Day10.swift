import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day10: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	static var cachedStartDirections: (Move, Move)?
	
	enum Pipe: String {
		case northSouth = "|"
		case eastWest = "-"
		case northEast = "L"
		case northWest = "J"
		case southWest = "7"
		case southEast = "F"
		case ground = "."
		case start = "S"
		
		var validMoves: [Move] {
			switch self {
			case .northSouth: return [.north, .south]
			case .eastWest: return [.east, .west]
			case .northEast: return [.north, .east]
			case .northWest: return [.north, .west]
			case .southWest: return [.south, .west]
			case .southEast: return [.south, .east]
			case .ground: return []
			case .start: return Move.allCases
			}
		}
	}
	
	enum Move: CaseIterable {
		case north
		case east
		case south
		case west
		
		var diff: (Int, Int) {
			switch self {
			case .north: (0, -1)
			case .east: (1, 0)
			case .south: (0, 1)
			case .west: (-1, 0)
			}
		}
		
		var opposite: Move {
			switch self {
			case .north: return .south
			case .east: return .west
			case .south: return .north
			case .west: return .east
			}
		}
	}
	
	struct Map {
		var pipes: [[Pipe]]
		var width: Int
		var height: Int
		
		func pipe(at: (Int, Int)) -> Pipe? {
			guard at.0 >= 0 && at.1 >= 0 && at.0 < width && at.1 < height else { return nil }
			return pipes[at.1][at.0]
		}
		
		func walkPath(from start: (Int, Int)) -> Int {
			var validStartDirections = [Move]()
			for move in Move.allCases {
				let pos = start + move.diff
				if pipe(at: pos)?.validMoves.contains(move.opposite) == true {
					validStartDirections.append(move)
				}
			}
			
			for option in validStartDirections.combinations(ofCount: 2) {
				if let result = testWalking(from: start, firstDirection: option[0], secondDirection: option[1]) {
					Day10.cachedStartDirections = (option[0], option[1])
					return result
				}
			}
			
			return 0
		}
		
		func testWalking(from start: (Int, Int), firstDirection: Move, secondDirection: Move) -> Int? {
			var firstDirection = firstDirection
			var firstPos = start + firstDirection.diff
			var secondDirection = secondDirection
			var secondPos = start + secondDirection.diff
			var distance = 1
			
			while firstPos != secondPos {
				guard let firstMove = pipe(at: firstPos), firstMove != .ground && firstMove != .start,
					  firstMove.validMoves.contains(firstDirection.opposite),
					  let nextFirst = firstMove.validMoves.filter({ $0 != firstDirection.opposite }).first,
					  let secondMove = pipe(at: secondPos), secondMove != .ground && secondMove != .start,
					  secondMove.validMoves.contains(secondDirection.opposite),
					  let nextSecond = secondMove.validMoves.filter({ $0 != secondDirection.opposite }).first else { return nil }
				
				distance += 1
				firstDirection = nextFirst
				firstPos = firstPos + firstDirection.diff
				secondDirection = nextSecond
				secondPos = secondPos + secondDirection.diff
			}
			
			return distance
		}
		
		func path(from start: (Int, Int), direction: Move) -> [(Int, Int)] {
			var direction = direction
			var pos = start + direction.diff
			var points = [start, pos]
			
			
			while pos != start {
				guard let move = pipe(at: pos), let next = move.validMoves.filter({ $0 != direction.opposite }).first else { return points }
				
				direction = next
				pos = pos + direction.diff
				points.append(pos)
			}
			
			return points
		}
		
		func findStart() -> (Int, Int) {
			for y in 0..<height {
				for x in 0..<width {
					if pipes[y][x] == .start {
						return (x, y)
					}
				}
			}
			
			fatalError("Couldn't find the start")
		}
		
		static func parsePipes(data: String) -> Map {
			let lines = data.components(separatedBy: .newlines)
			let pipes = lines.map({ line in line.map({ Pipe(rawValue: String($0))! })})
			assert(pipes.map({ $0.map(\.rawValue).joined() }).joined(separator: "\n") == data)
			
			return Map(pipes: pipes, width: pipes[0].count, height: pipes.count)
		}
	}
	
	func part1() -> Any {
		let map = Map.parsePipes(data: data)
		let start = map.findStart()
		return map.walkPath(from: start)
	}
	
	func part2() -> Any {
		let map = Map.parsePipes(data: data)
		let start = map.findStart()
		var directions = Self.cachedStartDirections
		if directions == nil {
			_ = map.walkPath(from: start)
			directions = Self.cachedStartDirections
		}
		
		guard let directions else { return 0 }
		
		let points = map.path(from: start, direction: directions.0)
		let path = CGMutablePath()
		path.move(to: CGPoint(x: start.0, y: start.1))
		for point in points.dropFirst() {
			path.addLine(to: CGPoint(x: point.0, y: point.1))
		}
		path.closeSubpath()
		
		var interiorPoints = 0
		for y in 0..<map.height {
			for x in 0..<map.width {
				if !points.contains(where: { $0.0 == x && $0.1 == y }) && path.contains(CGPoint(x: x, y: y)) {
					interiorPoints += 1
				}
			}
		}
		
		return interiorPoints
	}
}


func + (lhs: (Int, Int), rhs: (Int, Int)) -> (Int, Int) {
	(lhs.0 + rhs.0, lhs.1 + rhs.1)
}
