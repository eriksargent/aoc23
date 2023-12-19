import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue


struct Day19: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	typealias QuadrupleRange = ([ClosedRange<Int>], [ClosedRange<Int>], [ClosedRange<Int>], [ClosedRange<Int>])
	
	struct Workflow {
		var name: String
		var rules: [Rule]
		
		static func parse(from string: String) -> Workflow? {
			let prefix = string.prefix(while: { $0 != "{" })
			let name = String(prefix)
			let rules = string.dropFirst(prefix.count + 1).dropLast().components(separatedBy: ",").compactMap(Rule.parse(from:))
			return Workflow(name: name, rules: rules)
		}
	}
	
	indirect enum Rule {
		case reject
		case accept
		case reference(String)
		case greaterThan(KeyPath<Part, Int>, WritableKeyPath<QuadrupleRange, [ClosedRange<Int>]>, Int, Rule)
		case lessThan(KeyPath<Part, Int>, WritableKeyPath<QuadrupleRange, [ClosedRange<Int>]>, Int, Rule)
		
		static func parse(from string: String) -> Rule? {
			if string == "R" { return .reject }
			if string == "A" { return .accept }
			if !string.contains(":") { return .reference(string) }
			
			guard let source = string.first else { return nil }
			var keyPath = \Part.x
			var charPath = \QuadrupleRange.0
			if source == "m" {
				keyPath = \Part.m
				charPath = \.1
			}
			if source == "a" {
				keyPath = \Part.a
				charPath = \.2
			}
			if source == "s" {
				keyPath = \Part.s
				charPath = \.3
			}
			
			var isGreaterThan = false
			if string.dropFirst().first == ">" {
				isGreaterThan = true
			}
			let comps = string.dropFirst(2).components(separatedBy: ":")
			guard comps.count == 2, let value = Int(comps[0]) else { return nil }
			
			
			let rule: Rule
			if comps[1] == "R" {
				rule = .reject
			}
			else if comps[1] == "A" {
				rule = .accept
			}
			else {
				rule = .reference(comps[1])
			}
			
			if isGreaterThan {
				return .greaterThan(keyPath, charPath, value, rule)
			}
			else {
				return .lessThan(keyPath, charPath, value, rule)
			}
		}
	}
	
	struct Part: CustomStringConvertible {
		var x: Int
		var m: Int
		var a: Int
		var s: Int
		
		static func parse(from string: String) -> Part? {
			let (xRef, mRef, aRef, sRef) = (Reference(Int.self), Reference(Int.self), Reference(Int.self), Reference(Int.self))
			let regex = Regex {
				"{x="
				TryCapture(as: xRef, { OneOrMore(.digit) }, transform: { Int($0) })
				",m="
				TryCapture(as: mRef, { OneOrMore(.digit) }, transform: { Int($0) })
				",a="
				TryCapture(as: aRef, { OneOrMore(.digit) }, transform: { Int($0) })
				",s="
				TryCapture(as: sRef, { OneOrMore(.digit) }, transform: { Int($0) })
				"}"
			}
			guard let match = string.firstMatch(of: regex) else { return nil }
			return Part(x: match[xRef], m: match[mRef], a: match[aRef], s: match[sRef])
		}
		
		var description: String {
			"{x=\(x),m=\(m),a=\(a),s=\(s)}"
		}
		
		var total: Int {
			x + m + a + s
		}
	}
	
	func part1() async -> Any {
		let sections = data.components(separatedBy: .newlines).split(separator: "")
		guard sections.count == 2 else { return 0 }
		let workflows = sections[0].compactMap(Workflow.parse(from:))
		let parts = sections[1].compactMap(Part.parse(from:))
		
		assert(workflows.count == sections[0].count)
		assert(parts.count == sections[1].count)
		
		guard let startWorkflow = workflows.first(where: \.name, is: "in") else { return 0 }
		var workflowMap = [String: Workflow]()
		for workflow in workflows {
			workflowMap[workflow.name] = workflow
		}
		
		var total = 0
		for part in parts {
			var workflow = startWorkflow
			var partAnswer: Int?
			while partAnswer == nil {
				var forward: String?
				for rule in workflow.rules where partAnswer == nil && forward == nil {
					switch rule {
					case .reject:
						partAnswer = 0
					case .accept:
						partAnswer = part.total
					case .reference(let name):
						forward = name
					case .greaterThan(let keyPath, _, let value, let nextRule):
						if part[keyPath: keyPath] > value {
							switch nextRule {
							case .reject: partAnswer = 0
							case .accept: partAnswer = part.total
							case .reference(let ref): forward = ref
							default: break
							}
						}
					case .lessThan(let keyPath, _, let value, let nextRule):
						if part[keyPath: keyPath] < value {
							switch nextRule {
							case .reject: partAnswer = 0
							case .accept: partAnswer = part.total
							case .reference(let ref): forward = ref
							default: break
							}
						}
					}
				}
				if let forward {
					workflow = workflowMap[forward]!
				}
			}
			if let partAnswer = partAnswer {
				total += partAnswer
			}
		}
		
		return total
	}
	
	func part2() async -> Any {
		let sections = data.components(separatedBy: .newlines).split(separator: "")
		guard sections.count == 2 else { return 0 }
		let workflows = sections[0].compactMap(Workflow.parse(from:))
		
		guard let startWorkflow = workflows.first(where: \.name, is: "in") else { return 0 }
		let maxSample = 4000
		let fullRange = 1...maxSample
		let initialAcceptance = ([fullRange], [fullRange], [fullRange], [fullRange])
		var workflowQueue = [(startWorkflow, initialAcceptance)]
		
		var acceptedRanges: [QuadrupleRange] = []
		while let (workflow, startingAcceptance) = workflowQueue.popFirst() {
			var remaining = startingAcceptance
			for (ruleIndex, rule) in workflow.rules.enumerated() {
				switch rule {
				case .reject:
					continue
				case .accept:
					acceptedRanges.append(remaining)
				case .reference(let ref):
					let workflow = workflows.first(where: \.name, is: ref)!
					workflowQueue.append((workflow, remaining))
				case .greaterThan(_, let charPath, let value, let next):
					let badRange = (value + 1)...maxSample
					let goodRange = 1...value
					var acceptance = remaining
					acceptance[keyPath: charPath] = acceptance[keyPath: charPath].filter({ $0.overlaps(goodRange) }).flatMap({ $0.subtract(goodRange) })
					remaining[keyPath: charPath] = remaining[keyPath: charPath].filter({ $0.overlaps(badRange) }).flatMap({ $0.subtract(badRange) })
					
					switch next {
					case .accept: acceptedRanges.append(acceptance)
					case .reference(let ref): workflowQueue.append((workflows.first(where: \.name, is: ref)!, acceptance))
					default: continue
					}
					
				case .lessThan(_, let charPath, let value, let next):
					let goodRange = value...maxSample
					let badRange = 1...(value - 1)
					var acceptance = remaining
					acceptance[keyPath: charPath] = acceptance[keyPath: charPath].filter({ $0.overlaps(goodRange) }).flatMap({ $0.subtract(goodRange) })
					remaining[keyPath: charPath] = remaining[keyPath: charPath].filter({ $0.overlaps(badRange) }).flatMap({ $0.subtract(badRange) })
					
					switch next {
					case .accept: acceptedRanges.append(acceptance)
					case .reference(let ref): workflowQueue.append((workflows.first(where: \.name, is: ref)!, acceptance))
					default: continue
					}
				}
			}
		}
		
		return acceptedRanges.total()
	}
}


extension Array where Element == Day19.QuadrupleRange {
	func total() -> Int {
		var total = 0
		for (x, m, a, s) in self {
			let xTotal = x.map(\.count).sum()
			let mTotal = m.map(\.count).sum()
			let aTotal = a.map(\.count).sum()
			let sTotal = s.map(\.count).sum()
			total += xTotal * mTotal * aTotal * sTotal
		}
		return total
	}
}
