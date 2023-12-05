import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day05: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func part1() -> Any {
		let lines = data.components(separatedBy: .newlines)
		guard let headerLine = lines.first else { return 0 }
		
		var seeds = headerLine.trimmingPrefix("seeds: ").components(separatedBy: .whitespaces).compactMap(Int.init)
//		print("seeds: \(seeds)")
		
		var movedSeeds = seeds
		let blocks = lines.dropFirst(2).split(separator: "")
		for block in blocks {
			for map in block.dropFirst().reversed() {
//				print("\(block.first!) \(map)")
				let comps = map.components(separatedBy: .whitespaces).compactMap(Int.init)
				guard comps.count == 3 else {
					fatalError("Unexpected number of parameters")
				}
				
				let dest = comps[0]
				let start = comps[1]
				let size = comps[2]
				let source = start...(start + size)
				
				for (index, seed) in seeds.enumerated() {
					if source.contains(seed) {
//						print("  Moving \(seed) (index \(index)) to \(dest + seed - start)")
						movedSeeds[index] = dest + seed - start
					}
				}
			}
			seeds = movedSeeds
		}
		
//		print("seeds: \(seeds)")
		
		return seeds.min() ?? 0
	}
	
	func part2() -> Any {
		let lines = data.components(separatedBy: .newlines)
		guard let headerLine = lines.first else { return 0 }
		
		var seeds = headerLine.trimmingPrefix("seeds: ").components(separatedBy: .whitespaces).compactMap(Int.init).chunks(ofCount: 2).map({ $0.first!...($0.first! + $0.last! - 1) })
//		print("seeds: \(seeds)")
		
		let blocks = lines.dropFirst(2).split(separator: "")
		for block in blocks {
			var modifications = [(ClosedRange<Int>, Int)]()
			for map in block.dropFirst() {
//				print("\(block.first!) \(map)")
				let comps = map.components(separatedBy: .whitespaces).compactMap(Int.init)
				guard comps.count == 3 else {
					fatalError("Unexpected number of parameters")
				}
				
				let dest = comps[0]
				let start = comps[1]
				let size = comps[2]
				let source = start...(start + size - 1)
				let offset = dest - start
				
				// Turn this map into a range to move the source by the set offset. Make sure the ranges are unique by subtracting from the existing set
				var ranges = [source]
				for existing in modifications {
					var newRanges = [ClosedRange<Int>]()
					for range in ranges {
						newRanges.append(contentsOf: range.subtract(existing.0))
					}
					ranges = newRanges
				}
				
//				print("Reduced to: \(ranges) being moved with offset \(offset)")
				
				for range in ranges {
					modifications.append((range, offset))
				}
			}
			
			// Use the list of ranged-moves to offset the given subsets by the mapped amounts. Make sure to remove that subset so it can't be moved again, and leave the remainder in the list to potentially be moved
			var moved = [ClosedRange<Int>]()
			var ranges = seeds
			for mod in modifications {
				var remainingRanges = [ClosedRange<Int>]()
				for range in ranges {
					let (movedRange, remaining) = range.move(mod.0, by: mod.1)
					if let movedRange {
						moved.append(movedRange)
					}
					remainingRanges.append(contentsOf: remaining)
				}
				ranges = remainingRanges
			}
			ranges.append(contentsOf: moved)
			seeds = ranges.sorted(by: \.lowerBound)
//			print(modifications)
//			print("\(block.first!) \(seeds)")
		}
		
//		print("seeds: \(seeds)")
		
		return seeds.map(\.lowerBound).min() ?? 0
	}
}


extension ClosedRange<Int> {
	fileprivate func subtract(_ other: ClosedRange<Int>) -> [ClosedRange<Int>] {
		if other.lowerBound > self.upperBound || other.upperBound < self.lowerBound {
			return [self]
		}
		else if other.lowerBound > self.lowerBound && other.upperBound < self.upperBound {
			return [self.lowerBound...(other.lowerBound - 1), (other.upperBound + 1)...self.upperBound]
		}
		else if other.lowerBound <= self.lowerBound && other.upperBound >= self.upperBound {
			return []
		}
		else if other.lowerBound <= self.lowerBound && other.upperBound < self.upperBound {
			return [(other.upperBound + 1)...self.upperBound]
		}
		else if other.upperBound >= self.upperBound && other.lowerBound > self.lowerBound {
			return [self.lowerBound...(other.lowerBound - 1)]
		}
		else if (other.lowerBound < self.lowerBound && other.upperBound == self.upperBound) || (other.upperBound > self.upperBound && other.lowerBound == self.lowerBound) {
			return []
		}
		
		return []
	}
	
	fileprivate func move(_ subrange: ClosedRange<Int>, by offset: Int) -> (ClosedRange<Int>?, [ClosedRange<Int>]) {
		if subrange.lowerBound > self.upperBound || subrange.upperBound < self.lowerBound {
			return (nil, [self])
		}
		else if subrange.lowerBound > self.lowerBound && subrange.upperBound < self.upperBound {
			return ((subrange.lowerBound + offset)...(subrange.upperBound + offset), [self.lowerBound...(subrange.lowerBound - 1), (subrange.upperBound + 1)...self.upperBound])
		}
		else if subrange.lowerBound <= self.lowerBound && subrange.upperBound >= self.upperBound {
			return ((self.lowerBound + offset)...(self.upperBound + offset), [])
		}
		else if subrange.lowerBound <= self.lowerBound && subrange.upperBound < self.upperBound {
			return ((self.lowerBound + offset)...(subrange.upperBound + offset), [(subrange.upperBound + 1)...self.upperBound])
		}
		else if subrange.upperBound >= self.upperBound && subrange.lowerBound > self.lowerBound {
			return ((subrange.lowerBound + offset)...(self.upperBound + offset), [self.lowerBound...(subrange.lowerBound - 1)])
		}
		else if (subrange.lowerBound < self.lowerBound && subrange.upperBound == self.upperBound) || (subrange.upperBound > self.upperBound && subrange.lowerBound == self.lowerBound) {
			return ((self.lowerBound + offset)...(self.upperBound + offset), [])
		}

		return (nil, [self])
	}
}
