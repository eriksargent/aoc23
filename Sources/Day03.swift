import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day03: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	struct EngineTable: CustomStringConvertible {
		let width: Int
		let height: Int
		var grid: [[Symbol]]
		
		enum Symbol {
			case number(Int)
			case symbol(Character)
			case gear
			case empty
			
			static func symbol(from char: Character) -> Symbol {
				if char.isNumber, let number = Int(String(char)) {
					return .number(number)
				}
				else if char == "." {
					return .empty
				}
				else if char == "*" {
					return .gear
				}
				else {
					return .symbol(char)
				}
			}
			
			var stringValue: String {
				switch self {
				case .number(let number):
					return "\(number)"
				case .symbol(let symbol):
					return String(symbol)
				case .gear:
					return "*"
				case .empty:
					return "."
				}
			}
		}
		
		init(data: String) {
			let lines = data.components(separatedBy: .newlines)
			
			grid = lines.map { line in
				line.map(Symbol.symbol(from:))
			}
			height = grid.count
			width = grid.first?.count ?? 0
		}
		
		var description: String {
			"\(width)×\(height) Grid:\n" + gridString
		}
		
		var gridString: String {
			grid.map({ $0.map(\.stringValue).joined() }).joined(separator: "\n")
		}
		
		func getPartNums() -> [Int] {
			var valid = [Int]()
			
			for rowIndex in 0..<height {
				let row = grid[rowIndex]
				var index = 0
				while index < width {
					switch row[index] {
					case .empty, .symbol, .gear:
						index += 1
					case .number:
						if let (number, length) = getNumber(starting: index, row: rowIndex) {
							if findSymbol(starting: index, row: rowIndex, length: length) {
								valid.append(number)
							}
							index += length
						}
						else {
							index += 1
						}
					}
				}
			}
			
			return valid
		}
		
		func getNumber(starting: Int, row: Int, considerReverse: Bool = false) -> (number: Int, length: Int)? {
			guard case .number = grid[row][starting] else { return nil }
			var length = 0
			var number = 0
			var revLength = 0
			
			if considerReverse && starting > 0 {
				revLength = 1
				while starting - revLength >= 0, case .number = grid[row][starting - revLength] {
					revLength += 1
				}
				revLength -= 1
			}
			
			while starting - revLength + length < width {
				switch grid[row][starting - revLength + length] {
				case .empty, .symbol, .gear:
					return (number: number, length: length - revLength)
				case .number(let num):
					number = number * 10 + num
					length += 1
				}
			}
			
			return (number: number, length: length - revLength)
		}
		
		func findSymbol(starting: Int, row: Int, length: Int) -> Bool {
			let minColumn = max(starting - 1, 0)
			let maxColumn = min(starting + length, width - 1)
			
			if row > 0 {
				for index in minColumn...maxColumn {
					switch grid[row - 1][index] {
					case .symbol, .gear:
						return true
					default: continue
					}
				}
			}
			
			if starting > 0 {
				switch grid[row][starting - 1] {
				case .symbol, .gear: return true
				default: break
				}
			}
			else if starting + length < width {
				switch grid[row][starting + length] {
				case .symbol, .gear: return true
				default: break
				}
			}
			
			if row + 1 < height {
				for index in minColumn...maxColumn {
					switch grid[row + 1][index] {
					case .symbol, .gear:
						return true
					default: continue
					}
				}
			}
			
			return false
		}
		
		func getGearRatios() -> [Int] {
			var ratios = [Int]()
			
			for rowIndex in 0..<height {
				let row = grid[rowIndex]
				for index in 0..<width {
					switch row[index] {
					case .gear:
						let adjacentParts = findAdjacentNumbers(at: index, row: rowIndex)
						if adjacentParts.count == 2 {
							ratios.append(adjacentParts.reduce(1, *))
						}
					default:
						break
					}
				}
			}
			
			return ratios
		}
		
		func findAdjacentNumbers(at column: Int, row: Int) -> [Int] {
			let minColumn = max(column - 1, 0)
			let maxColumn = min(column + 1, width - 1)
			var adjacentNumbers = [Int]()
			
			if row > 0 {
				var index = minColumn
				while index <= maxColumn {
					if let (number, length) = getNumber(starting: index, row: row - 1, considerReverse: true) {
						adjacentNumbers.append(number)
						index += length
					}
					else {
						index += 1
					}
				}
			}
			
			if column > 0, let (number, _) = getNumber(starting: column - 1, row: row, considerReverse: true) {
				adjacentNumbers.append(number)
			}
			if column + 1 < width, let (number, _) = getNumber(starting: column + 1, row: row, considerReverse: true) {
				adjacentNumbers.append(number)
			}
			
			if row + 1 < height {
				var index = minColumn
				while index <= maxColumn {
					if let (number, length) = getNumber(starting: index, row: row + 1, considerReverse: true) {
						adjacentNumbers.append(number)
						index += length
					}
					else {
						index += 1
					}
				}
			}
			
			return adjacentNumbers
		}
	}
	
	func part1() -> Any {
		let input = data.trimmingCharacters(in: .whitespacesAndNewlines)
		let table = EngineTable(data: input)
//		print(table)
		assert(table.gridString == input)
		let partNumbers = table.getPartNums()
//		print(partNumbers)
		return partNumbers.sum()
	}
	
	func part2() -> Any {
		let input = data.trimmingCharacters(in: .whitespacesAndNewlines)
		let table = EngineTable(data: input)
//		print(table)
		assert(table.gridString == input)
		let gearRatios = table.getGearRatios()
//		print(gearRatios)
		return gearRatios.sum()
	}
}
