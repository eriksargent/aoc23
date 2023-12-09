import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day09: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func nextValue(from line: [Int]) -> Int {
		let diffs = line.adjacentPairs().map({ $0.1 - $0.0 })
		if diffs.allSatisfy({ $0 == 0 }) {
			return line.last ?? 0
		}
		else {
			return (line.last ?? 0) + nextValue(from: diffs)
		}
	}
	
	func previousValue(from line: [Int]) -> Int {
		let diffs = line.adjacentPairs().map({ $0.1 - $0.0 })
		if diffs.allSatisfy({ $0 == 0 }) {
			return line.first ?? 0
		}
		else {
			return (line.first ?? 0) - previousValue(from: diffs)
		}
	}
	
	func part1() -> Any {
		let lines = data.components(separatedBy: .newlines).map({ $0.components(separatedBy: .whitespaces).compactMap(Int.init) })
		return lines.map({ nextValue(from: $0) }).sum()
	}
	
	func part2() -> Any {
		let lines = data.components(separatedBy: .newlines).map({ $0.components(separatedBy: .whitespaces).compactMap(Int.init) })
		return lines.map({ previousValue(from: $0) }).sum()
	}
}
