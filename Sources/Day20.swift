import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics
import SwiftPriorityQueue


private enum Pulse: CustomStringConvertible {
	case high
	case low
	
	var description: String {
		switch self {
		case .high: return "high"
		case .low: return "low"
		}
	}
}


private protocol Module: CustomStringConvertible {
	static var prefix: String { get }
	var name: String { get set }
	var outputs: [String] { get set }
	var state: Bool { get set }
	var outputState: Pulse { get }
	
	mutating func receive(_ pulse: Pulse, from source: String) -> (sendPulse: Pulse, to: [String])?
	
	init()
	init?(from string: String)
}


extension Module {
	fileprivate static func parseOutputs(from string: String) -> [String]? {
		let listRef = Reference([String].self)
		let regex = Regex {
			OneOrMore { .any }
			"-> "
			Capture(as: listRef, {
				OneOrMore {
					OneOrMore {
						.word
					}
					ZeroOrMore {
						", "
					}
				}
			}, transform: {
				$0.components(separatedBy: ", ").map({ String($0) })
			})
		}
		
		guard let match = try? regex.firstMatch(in: string) else { return nil }
		
		return match[listRef]
	}
	
	init?(from string: String) {
		guard string.starts(with: Self.prefix) else { return nil }
		let comps = string.dropFirst().components(separatedBy: " ")
		guard let name = comps.first, let outputs = Self.parseOutputs(from: string) else { return nil }
		
		self.init()
		self.name = name
		self.outputs = outputs
		self.state = false
	}
	
	var typeName: String {
		String(describing: Self.self)
	}
	
	var description: String {
		"\(typeName)(\(name) - \(state) -> \(outputs.joined(separator: ", ")))"
	}
}


private class FlipFlop: Module {
	static let prefix = "%"
	var name = ""
	var outputs: [String] = []
	var state = false
	var outputState: Pulse {
		state ? .high : .low
	}
	
	required init() { }
	func receive(_ pulse: Pulse, from source: String) -> (sendPulse: Pulse, to: [String])? {
		guard pulse == .low else { return nil }
		
		state.toggle()
		return (sendPulse: outputState, to: outputs)
	}
	
	init(name: String) {
		self.name = name
	}
}


private class Conjunction: Module {
	static let prefix = "&"
	var name = ""
	var outputs: [String] = []
	var inputs: [String: Pulse] = [:]
	var state = false
	var outputState: Pulse {
		state ? .low : .high
	}
	
	required init() { }
	func receive(_ pulse: Pulse, from source: String) -> (sendPulse: Pulse, to: [String])? {
		inputs[source] = pulse
		state = inputs.values.allSatisfy({ $0 == .high })
		return (sendPulse: outputState, to: outputs)
	}
	
	func setupInputs(_ inputs: [String]) {
		self.inputs = inputs.reduce(into: [:], { $0[$1] = .low })
	}
	
	
	var description: String {
		"\(typeName)(\(inputs.map({ "\($0.key):\($0.value)" }).joined(separator: ", ")) -> \(name) - \(state) -> \(outputs.joined(separator: ", ")))"
	}
}

private class Broadcaster: Module {
	static let prefix = "broadcaster"
	var name = ""
	var outputs: [String] = []
	var state = false
	var outputState: Pulse { state ? .high : .low }
	
	func receive(_ pulse: Pulse, from source: String) -> (sendPulse: Pulse, to: [String])? {
		state = pulse == .high
		return (sendPulse: pulse, to: outputs)
	}
	
	required init() { }
	
	required init?(from string: String) {
		guard string.starts(with: Self.prefix) else { return nil }
		guard let outputs = Self.parseOutputs(from: string) else { return nil }
		
		self.name = Self.prefix
		self.outputs = outputs
	}
}


struct Day20: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	fileprivate func pressButton(modules: inout [String: Module]) -> (highs: Int, lows: Int) {
		var highs = 0
		var lows = 1
		
		var queue = [(name: Broadcaster.prefix, pulse: Pulse.low, source: "button")]
		while let next = queue.popFirst() {
			guard let output = modules[next.name]?.receive(next.pulse, from: next.source) else { continue }
			queue.append(contentsOf: output.to.map({ (name: $0, pulse: output.sendPulse, source: next.name) }))
			if output.sendPulse == .high {
				highs += output.to.count
			}
			else {
				lows += output.to.count
			}
		}
		
		return (highs: highs, lows: lows)
	}
	
	fileprivate func getModules() -> [String: Module] {
		var modules: [String: Module] = [:]
		data.components(separatedBy: .newlines).forEach { line in
			if let module = FlipFlop(from: line) {
				modules[module.name] = module
			}
			else if let module = Conjunction(from: line) {
				modules[module.name] = module
			}
			else if let module = Broadcaster(from: line) {
				modules[module.name] = module
			}
		}
		
		for conjunction in modules.values.compactMap({ $0 as? Conjunction }) {
			conjunction.setupInputs(modules.values.filter({ $0.outputs.contains(conjunction.name) }).map(\.name))
		}
		
		return modules
	}
	
	func part1() async -> Any {
		var modules = getModules()
		var highs = 0
		var lows = 0
		for _ in 0..<1000 {
			let (high, low) = pressButton(modules: &modules)
			highs += high
			lows += low
		}
		return highs * lows
	}
	
	func part2() async -> Any {
		var modules = getModules()
		guard let feedingRx = modules.values.first(where: { $0.outputs.contains("rx") }) as? Conjunction else { return 0 }
		
		let inputKeys = feedingRx.inputs.keys
		var feedingCounts = feedingRx.inputs.keys.reduce(into: [String: Int](), { $0[$1] = 0 })
		var presses = 0
		while !feedingCounts.values.allSatisfy({ $0 != 0 }) {
			presses += 1
			
			var queue = [(name: Broadcaster.prefix, pulse: Pulse.low, source: "button")]
			while let next = queue.popFirst() {
				guard let output = modules[next.name]?.receive(next.pulse, from: next.source) else { continue }
				queue.append(contentsOf: output.to.map({ (name: $0, pulse: output.sendPulse, source: next.name) }))
				
				if inputKeys.contains(next.name) && modules[next.name]?.outputState == .high && feedingCounts[next.name] == 0 {
					feedingCounts[next.name] = presses
				}
			}
		}
		
		return ArraySlice(feedingCounts.values).lcm()
	}
}
