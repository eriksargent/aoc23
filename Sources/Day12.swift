import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day12: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	actor Cache {
		var _cache: [String: Bool] = [:]
		
		func get(_ key: String) -> Bool? {
			return _cache[key]
		}
		
		func set(_ key: String, value: Bool) {
			_cache[key] = value
		}
	}
	
	func hashes(length: Int) -> String {
		return String(Array<Character>.init(repeating: "#", count: length))
	}
	
	func possibleArrangements(for line: String, unfold: Bool, cache: Cache) async -> Int {
		guard line.contains("?") else {
			return 0
		}
		
		let comps = line.split(separator: " ")
		var groups = comps[0].components(separatedBy: ".").filter({ $0 != "" })
		var parity = comps[1].components(separatedBy: ",").compactMap(Int.init)
		
		if unfold {
			groups = [String](repeating: String(comps[0]), count: 5).joined(separator: "?").components(separatedBy: ".").filter({ $0 != "" })
			parity = [[Int]](repeating: parity, count: 5).flatMap({ $0 })
		}
		
		return await accumulate(string: groups.joined(separator: "."), parity: ArraySlice(parity), cache: cache)
	}
	
//	static var validCache = Cache()
	func isSequenceValid(string: String, parity: ArraySlice<Int>, tooLong: String, cache: Cache) async -> Bool {
		let key = key(from: string, parity: parity)
		if let cached = await cache.get(key) {
			return cached
		}
		
		if (parity.isEmpty && string.contains(/(\#|\?)/)) ||
			(string == "" && !parity.isEmpty) ||
			(string.filter({ $0 == "#" }).count > parity.sum()) ||
			(parity.sum() + parity.count - 1 > string.count) ||
			string.contains(tooLong) {
			await cache.set(key, value: false)
			return false
		}
		
		let groups = string.components(separatedBy: ".").filter({ $0 != "" })
		for (group, parity) in zip(groups, parity) {
			if group == hashes(length: parity) {
				continue
			}
			else if group.contains("?") {
				await cache.set(key, value: true)
				return true
			}
			else {
				await cache.set(key, value: false)
				return false
			}
		}
		
		await cache.set(key, value: true)
		return true
	}
	
	func prune(string: String, parity: ArraySlice<Int>) -> (string: String, parity: ArraySlice<Int>) {
		var groups = string.components(separatedBy: ".").filter({ $0 != "" })
		var parity = parity
		if let index = zip(groups, parity).enumerated().lazy.filter({ (_, arg1) in
			let (group, parity) = arg1
			return !(group.count == parity && !group.contains("?"))
		}).map(\.0).first, index > 0 {
			groups.removeFirst(index)
			parity.removeFirst(index)
		}
		
		return (groups.joined(separator: "."), ArraySlice(parity))
	}
	
	func getBlock(string: String, parity: ArraySlice<Int>, count: Int) -> [(string: String, parity: ArraySlice<Int>, count: Int)] {
		let questions = string.filter({ $0 == "?" }).count
		let qcount =  min(questions, 5)
		let fills = Set([[String]](repeating: [".", "#"], count: qcount).flatMap({ $0 }).combinations(ofCount: qcount).map({ $0 }))
		var blocks = [(string: String, parity: ArraySlice<Int>, count: Int)]()
		for var fill in fills {
			var newString = ""
			for character in string {
				if character != "?" {
					newString += String(character)
				}
				else {
					if !fill.isEmpty {
						newString += fill.removeFirst()
					}
					else {
						newString += String(character)
					}
				}
			}
			blocks.append((newString, parity, count))
		}
		
		return blocks
	}
	
	func key(from string: String, parity: ArraySlice<Int>) -> String {
		string + ":" + parity.map({ String($0) }).joined(separator: "-")
	}
	
	func accumulate(string: String, parity: ArraySlice<Int>, cache: Cache) async -> Int {
		var heap = [String: Int]()
		var newHeap = [String: Int]()
		var block = getBlock(string: string, parity: parity, count: 1)
		let tooLong = hashes(length: (parity.max() ?? 1) + 1)
		for (string, parity, count) in block {
			let (newString, newParity) = prune(string: string, parity: parity)
			if await isSequenceValid(string: newString, parity: newParity, tooLong: tooLong, cache: cache) {
				let key = key(from: newString, parity: newParity)
				if let existing = newHeap[key] {
					newHeap[key] = existing + count
				}
				else {
					newHeap[key] = count
				}
			}
		}
		
		var hasQuestion = newHeap.keys.first?.contains("?") == true
		while hasQuestion {
			heap = newHeap
			newHeap = [:]
			block = []
			for (key, count) in heap {
				let comps = key.components(separatedBy: ":")
				if comps.count != 2 { continue }
				let string = comps[0]
				let parity = ArraySlice(comps[1].components(separatedBy: "-").compactMap(Int.init))
				block.append(contentsOf: getBlock(string: string, parity: parity, count: count))
			}
			
			for (string, parity, count) in block {
				let (newString, newParity) = prune(string: string, parity: parity)
				if await isSequenceValid(string: newString, parity: newParity, tooLong: tooLong, cache: cache) {
					let key = key(from: newString, parity: newParity)
					if let existing = newHeap[key] {
						newHeap[key] = existing + count
					}
					else {
						newHeap[key] = count
					}
				}
			}
			
			hasQuestion = newHeap.keys.first?.contains("?") == true
		}
		
		return newHeap.values.sum()
	}
	
	func part1() async -> Any {
		let lines = data.components(separatedBy: .newlines)
		var total = 0
		for line in lines {
			total += await possibleArrangements(for: line, unfold: false, cache: Cache())
		}
		return total
	}
	
	func part2() async -> Any {
		let lines = data.components(separatedBy: .newlines)

		return await withTaskGroup(of: Int.self, returning: Int.self) { group in
			for (chunkIndex, chunk) in lines.chunks(ofCount: max(lines.count / 12, 1)).enumerated() {
				group.addTask {
					var cache = Cache()
					var total = 0
					for (index, line) in chunk.enumerated() {
						total += await possibleArrangements(for: line, unfold: true, cache: cache)
					}
					return total
				}
			}
			
			var results = 0
			for await result in group {
				results += result
			}
			
			return results
		}
	}
}
