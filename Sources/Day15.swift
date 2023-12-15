import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day15: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func hash(_ string: String) -> Int {
		var hash = 0
		for char in string {
			hash = ((hash + Int(char.asciiValue!)) * 17) % 256
		}
		return hash
	}
	
	func part1() async -> Any {
		return data.components(separatedBy: ",").map(hash).sum()
	}
	
	func part2() async -> Any {
		var boxes = [[(String, Int)]](repeating: [], count: 256)
		for line in data.components(separatedBy: ",") {
			let parts = line.components(separatedBy: CharacterSet(arrayLiteral: "-", "="))
			let hash = self.hash(parts[0])
			// Remove
			if parts[1] == "", let index = boxes[hash].firstIndex(where: \.0, is: parts[0]) {
				boxes[hash].remove(at: index)
			}
			// Add
			else if let power = Int(parts[1]) {
				if let index = boxes[hash].firstIndex(where: \.0, is: parts[0]) {
					boxes[hash][index].1 = power
				}
				else {
					boxes[hash].append((parts[0], power))
				}
			}
		}
		
		var totalFocus = 0
		for (boxIndex, box) in boxes.enumerated() {
			for (slotIndex, slot) in box.enumerated() {
				totalFocus += (boxIndex + 1) * (slotIndex + 1) * slot.1
			}
		}
		
		return totalFocus
	}
}
