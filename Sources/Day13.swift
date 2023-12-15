import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day13: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func testPattern(_ pattern: ArraySlice<String>, pairsTest: (AdjacentPairsSequence<EnumeratedSequence<ArraySlice<String>>>.Iterator.Element) -> Bool, testFunction: (Zip2Sequence<ArraySlice<String>.SubSequence, ReversedCollection<ArraySlice<String>>>) -> (Bool)) -> [(Int, Int)] {
		let pairsToTest = pattern
			.enumerated()
			.adjacentPairs()
			.filter(pairsTest)
			.filter {
				let size = min($0.offset + 1, pattern.count - $1.offset)
				let leftEnd = ($0.offset + pattern.startIndex)
				let rightStart = (pattern.startIndex + $1.offset)
//				print(size)
//				print($0)
//				print($1)
				return testFunction(
					zip(pattern[(leftEnd - size + 1)...leftEnd], pattern[rightStart..<(rightStart + size)].reversed())
				)
			}
		
		
//		if let offset = pairsToTest.first?.0.offset {
//			print(offset + 1)
//			return offset + 1
//		}
//		
//		return nil
		
		return pairsToTest.map { ($0.1.offset, min($0.0.offset + 1, pattern.count - $0.1.offset)) }
	}
	
	func findPattern(in pattern: ArraySlice<String>, pairsTest: (AdjacentPairsSequence<EnumeratedSequence<ArraySlice<String>>>.Iterator.Element) -> Bool, testFunction: (Zip2Sequence<ArraySlice<String>.SubSequence, ReversedCollection<ArraySlice<String>>>) -> (Bool)) -> Int {
		var results = [(Int, Int)]()
		
		results.append(
			contentsOf:
				testPattern(pattern, pairsTest: pairsTest, testFunction: testFunction)
				.map({ ($0.0 * 100, $0.1) })
		)
		
		if !results.isEmpty {
			return results.sorted(by: \.1, ascending: false).first?.0 ?? 0
		}
		
		let transposed = pattern.map({ Array($0) }).transposed().map({ String($0) })
		results.append(contentsOf: testPattern(ArraySlice(transposed), pairsTest: pairsTest, testFunction: testFunction))
		
		return results.sorted(by: \.1, ascending: false).first?.0 ?? 0
	}
	
	func part1() async -> Any {
		let patterns = data.components(separatedBy: .newlines).split(separator: "")
		
		return patterns.map({ pattern in
			findPattern(in: pattern, pairsTest: { $0.1 == $1.1 }, testFunction: {
				$0.allSatisfy(==)
			})
		}).sum()
	}
	
	func part2() async -> Any {
		let patterns = data.components(separatedBy: .newlines).split(separator: "")
		
		return patterns.map({ pattern in
			findPattern(in: pattern, pairsTest: { pairs in
				zip(Array(arrayLiteral: pairs.0), Array(arrayLiteral: pairs.1)).filter(!=).count == 1
			}, testFunction: { zipSequence in
				zipSequence.map({ (lhs, rhs) in
					zip(Array(arrayLiteral: lhs), Array(arrayLiteral: rhs)).filter(!=).count
				}).sum() == 1
			})
		}).sum()
	}
}


extension Collection where Self.Iterator.Element: RandomAccessCollection {
	func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
		guard let firstRow = self.first else { return [] }
		return firstRow.indices.map { index in
			self.map{ $0[index] }
		}
	}
}
