import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day11: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func calculate(scale: Int = 1) -> Int {
		let lines = data.components(separatedBy: .newlines)
		var locations = lines.enumerated().flatMap({ y, line in
			line.enumerated().filter(where: \.element, is: "#").map({ ($0.offset, y) })
		})
		let width = lines[0].count
		let height = lines.count
		
		for x in (0..<width).reversed() {
			// Expand Column
			if locations.allSatisfy({ $0.0 != x }) {
				locations.enumerated().filter({ $0.element.0 > x }).forEach { (index, location) in
					locations[index] = (location.0 + scale, location.1)
				}
			}
		}
		for y in (0..<height).reversed() {
			// Expand Row
			if locations.allSatisfy({ $0.1 != y }) {
				locations.enumerated().filter({ $0.element.1 > y }).forEach { (index, location) in
					locations[index] = (location.0, location.1 + scale)
				}
			}
		}
		
		let distances = locations.combinations(ofCount: 2).map({ abs($0[1].0 - $0[0].0) + abs($0[1].1 - $0[0].1) })
		
		return distances.sum()
	}
	
	func part1() -> Any {
		calculate(scale: 1)
	}
	
	func part2() -> Any {
		return part2(scale: 1000000 - 1)
	}
	
	func part2(scale: Int) -> Any {
		calculate(scale: scale)
	}
}
