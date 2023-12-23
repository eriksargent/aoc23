import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue

struct Day22: AdventDay {
	var data: String
	
	struct Point3: Equatable {
		var x: Int
		var y: Int
		var z: Int
		
		init(_ x: Int, _ y: Int, _ z: Int) {
			self.x = x
			self.y = y
			self.z = z
		}
		
		init?(from string: String) {
			let components = string.components(separatedBy: ",").compactMap(Int.init)
			guard components.count == 3 else { return nil }
			self.init(components[0], components[1], components[2])
		}
	}
	
	class Cube: Equatable {
		var index: Int = 0
		var start: Point3
		var end: Point3
		var supports: [Int] = []
		var supportedBy: [Int] = []
		
		static func == (lhs: Cube, rhs: Cube) -> Bool {
			lhs.start == rhs.start && lhs.end == rhs.end
		}
		
		init(index: Int, start: Point3, end: Point3) {
			self.index = index
			self.start = start
			self.end = end
		}
		
		convenience init?(from string: String, index: Int) {
			let points = string.components(separatedBy: "~").compactMap(Point3.init(from:))
			guard points.count == 2 else { return nil }
			self.init(index: index, start: points[0], end: points[1])
		}
		
		var xRange: ClosedRange<Int> { start.x...end.x }
		
		var yRange: ClosedRange<Int> { start.y...end.y }
	}
	
	class Map {
		var cubes: [Cube]
		
		init(from string: String) {
			let lines = string.components(separatedBy: .newlines)
			let cubes = lines.enumerated().compactMap({ Cube.init(from: $1, index: $0) }).sorted(by: \.start.z, ascending: true)
			self.cubes = cubes.sorted(by: \.start.z, ascending: true)
			for (index, cube) in cubes.enumerated() {
				cube.index = index
			}
		}
		
		func collapse() {
			for cube in cubes {
				var foundBelow = false
				var shiftedZ = cube.start.z - 1
				while !foundBelow && shiftedZ > 0 {
					if cubes.first(where: { $0.end.z == shiftedZ && $0.xRange.overlaps(cube.xRange) && $0.yRange.overlaps(cube.yRange) }) != nil {
						foundBelow = true
					}
					else {
						shiftedZ -= 1
					}
				}
				
				shiftedZ += 1
				if shiftedZ < cube.start.z {
					let diff = cube.start.z - shiftedZ
					cube.start.z -= diff
					cube.end.z -= diff
				}
			}
			
			for (index, cube) in cubes.enumerated() {
				if index > 0 {
					cube.supportedBy = cubes[0..<index].filter({ $0.end.z == cube.start.z - 1 && $0.xRange.overlaps(cube.xRange) && $0.yRange.overlaps(cube.yRange) }).map(\.index)
				}
				if index + 1 < cubes.count {
					cube.supports = cubes[(index + 1)...].filter({ $0.start.z == cube.end.z + 1 && $0.xRange.overlaps(cube.xRange) && $0.yRange.overlaps(cube.yRange) }).map(\.index)
				}
			}
		}
		
		func countDisintegratable() -> Int {
			var count = 0
			for cube in cubes {
				if cube.supports.isEmpty {
					count += 1
				}
				else if cube.supports.allSatisfy({ cubes[$0].supportedBy.count > 1 }) {
					count += 1
				}
			}
			return count
		}
		
		func collapsablePerBrick() -> Int {
			var collapsable = [Int: Int]()
			for cube in cubes {
				if cube.supports.isEmpty {
					collapsable[cube.index] = 0
				}
				else {
					var removed = Set([cube.index])
					var searchSpace = cube.supports
					while let nextIndex = searchSpace.popFirst() {
						let supportedCube = cubes[nextIndex]
						if Set(supportedCube.supportedBy).subtracting(removed).isEmpty {
							removed.insert(supportedCube.index)
							searchSpace.append(contentsOf: supportedCube.supports)
						}
					}
					
					collapsable[cube.index] = removed.count - 1
				}
			}
			
			return collapsable.values.sum()
		}
	}
	
	func part1() async -> Any {
		let map = Map(from: data)
		map.collapse()
		return map.countDisintegratable()
	}
	
	func part2() async -> Any {
		let map = Map(from: data)
		map.collapse()
		return map.collapsablePerBrick()
	}
}


extension Array where Element == ClosedRange<Int> {
	func overlaps(_ other: Element) -> Bool {
		for range in self {
			if range.overlaps(other) {
				return true
			}
		}
		return false
	}
}
