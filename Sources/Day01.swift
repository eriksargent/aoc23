import Algorithms
import Foundation


struct Day01: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	// Splits input data into its component parts and convert from string.
	var entities: [Int] {
		data
			.components(separatedBy: .newlines).filter({ $0 != "" }).map {
			let chars = $0.filter({ $0.isNumber })
			return "\(chars.first!)\(chars.last!)"
		}
		.compactMap(Int.init)
	}
	
	// Replace this with your solution for the first part of the day's challenge.
	func part1() -> Any {
		// Calculate the sum of the first set of input data
		entities.reduce(0, +)
	}
	
	// Replace this with your solution for the second part of the day's challenge.
	func part2() -> Any {
		var lines = data.components(separatedBy: .newlines).filter({ $0 != "" })
		
		do {
			let regex = try Regex("(one|two|three|four|five|six|seven|eight|nine)")
			let parser = NumberFormatter()
			parser.numberStyle = .spellOut
			lines = lines.map {
				var line = $0
				
				var startIndex = line.startIndex
				while let first = line[startIndex...].matches(of: regex).flatMap({ $0.output }).first, 
						let value = first.substring,
						let number = parser.number(from: String(value))?.intValue,
						let range = first.range {
					line.insert(contentsOf: "\(number)", at: range.lowerBound)
					startIndex = line.index(range.lowerBound, offsetBy: 2)
				}
				
//				print("in: \($0) out: \(line)")
				return line
			}
		}
		catch let error {
			print(error)
		}
		
		let values = lines.map {
			let chars = $0.filter({ $0.isNumber })
			return "\(chars.first!)\(chars.last!)"
		}
		.compactMap(Int.init)
		
		return values.reduce(0, +)
	}
}
