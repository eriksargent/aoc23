import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day08: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String

	func part1() -> Any {
		let lines = data.components(separatedBy: .newlines)
		guard lines.count > 2 else { return -1 }
		
		let instructions = lines[0].map { $0 == "L" }
		
		var nodes = [String: (String, String)]()
		
		for line in lines {
			if let (_, node, left, right) = line.firstMatch(of: /(\w{3}) = \((\w{3}), (\w{3})\)/)?.output {
				nodes[String(node)] = (String(left), String(right))
			}
		}
		
		var node = "AAA"
		var instructionIndex = 0
		var steps = 0
		while node != "ZZZ" {
			if instructionIndex >= instructions.count {
				instructionIndex = 0
			}
			
			if let options = nodes[node] {
				if instructions[instructionIndex] {
					node = options.0
				}
				else {
					node = options.1
				}
			}
			else {
				return -1
			}
			
			instructionIndex += 1
			steps += 1
		}
		
		return steps
	}

	func part2() -> Any {
		let lines = data.components(separatedBy: .newlines)
		guard lines.count > 2 else { return -1 }
		
		let instructions = lines[0].map { $0 == "L" }
		
		var nodes = [String: (String, String)]()
		
		for line in lines {
			if let (_, node, left, right) = line.firstMatch(of: /(\w{3}) = \((\w{3}), (\w{3})\)/)?.output {
				nodes[String(node)] = (String(left), String(right))
			}
		}
		
		var instructionIndex = 0
		var steps = 0
		var minSteps = [Int]()
		for startingNode in nodes.keys.filter({ $0.last == "A" }) {
			var node = startingNode
			instructionIndex = 0
			steps = 0
			
			while node.last != "Z" {
				if instructionIndex >= instructions.count {
					instructionIndex = 0
				}
				
				if let options = nodes[node] {
					if instructions[instructionIndex] {
						node = options.0
					}
					else {
						node = options.1
					}
				}
				else {
					return -1
				}
				
				instructionIndex += 1
				steps += 1
			}
			
			minSteps.append(steps)
		}
		
		return minSteps[0..<minSteps.endIndex].lcm()
	}
}


extension Int {
	func gcd(with other: Int) -> Int {
		var first = self
		var second = other
		while second != 0 {
			let temp = second
			second = first % second
			first = temp
		}
		return first
	}
	
	func lcm(with other: Int) -> Int {
		(self * other ) / self.gcd(with: other)
	}
}


extension ArraySlice<Int> {
	func lcm() -> Int {
		if count == 2 {
			return self[self.startIndex].lcm(with: self[self.endIndex - 1])
		}
		else if count > 2 {
			return self[self.startIndex].lcm(with: self[self.index(after: self.startIndex)..<self.endIndex].lcm())
		}
		else {
			return 1
		}
	}
}
