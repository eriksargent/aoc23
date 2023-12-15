import Algorithms
import Foundation
import RegexBuilder
import AppUtils
import CoreGraphics


struct Day12: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func possibleArrangements(for line: String, unfold: Bool, cache: NSCache<NSString, NSString>) -> Int {
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
		
		let result = search(string: groups.joined(separator: "."), parity: ArraySlice(parity), cache: cache)!.map({ $0.replacingOccurrences(of: "?", with: ".") })
		
		let countUnique = Set(result).count
//		print("line \(line) had a result of \(result.count)")
//		print("Produced unique options: \(result)")
		
		return countUnique
	}
	
	func search(string: String, parity: ArraySlice<Int>, cache: NSCache<NSString, NSString>) -> [String]? {
		let cacheKey = NSString(string: "\(string)\(parity.map({ String($0) }).joined(separator: "-"))")
		let shouldCache = cacheKey.length < 20
		if shouldCache, let existing = cache.object(forKey: cacheKey) {
			if existing == "" {
				return nil
			}
			else {
				return existing.components(separatedBy: ";")
			}
		}
		
		if parity.isEmpty {
			if string.contains("#") {
				if shouldCache {
					cache.setObject(NSString(string: ""), forKey: cacheKey)
				}
				return nil
			}
			else {
				return [string]
			}
		}
		else if string.isEmpty {
			if shouldCache {
				cache.setObject(NSString(string: ""), forKey: cacheKey)
			}
			return nil
		}
		
		var groupLength = -1
		for (index, character) in string.indexed() {
			if character == "#" {
				if groupLength < 0 {
					groupLength = 1
				}
				else {
					groupLength += 1
				}
				
				if let first = parity.first, groupLength > first {
					if shouldCache {
						cache.setObject(NSString(string: ""), forKey: cacheKey)
					}
					return nil
				}
				else if groupLength == parity.first, string.index(after: index) == string.endIndex && parity.count == 1 {
					if shouldCache {
						cache.setObject(NSString(string: string), forKey: cacheKey)
					}
					return [string]
				}
				else if groupLength == parity.first && string[index...].dropFirst().first != "#" {
					let substring = String(string[string.index(after: index)...].dropFirst())
					let leadingString = String(string[string.startIndex...index]) + "."
					let results = search(string: substring, parity: parity.dropFirst(), cache: cache)
					let toReturn = results?.map({ leadingString + $0 })
					if shouldCache {
						cache.setObject(NSString(string: toReturn?.joined(separator: ";") ?? ""), forKey: cacheKey)
					}
					return toReturn
				}
			}
			else if character == "." {
				if groupLength < 1 {
					continue
				}
				else if groupLength == parity.first {
					let substring = String(string[string.index(after: index)...])
					let leadingString = String(string[string.startIndex...index])
					let results = search(string: substring, parity: parity.dropFirst(), cache: cache)
					let toReturn = results?.map({ leadingString + $0 })
					if shouldCache {
						cache.setObject(NSString(string: toReturn?.joined(separator: ";") ?? ""), forKey: cacheKey)
					}
					return toReturn
				}
				else {
					if shouldCache {
						cache.setObject(NSString(string: ""), forKey: cacheKey)
					}
					return nil
				}
			}
			else if character == "?" {
				if groupLength == parity.first || (groupLength == -1 && parity.first == 1 && string.index(after: index) == string.endIndex) {
					var modString = string
					if groupLength == parity.first {
						modString = String(string.replacingCharacters(in: index..<string.index(after: index), with: "."))
					}
					else {
						modString = String(string.replacingCharacters(in: index..<string.index(after: index), with: "#"))
					}
					if string.index(after: index) == string.endIndex {
						if parity.count == 1 {
							if shouldCache {
								cache.setObject(NSString(string: modString), forKey: cacheKey)
							}
							return [modString]
						}
						else {
							if shouldCache {
								cache.setObject(NSString(string: ""), forKey: cacheKey)
							}
							return nil
						}
					}
					let leadingString = String(modString[string.startIndex...index])
					let substring = String(string[string.index(after: index)...])
					let results = search(string: substring, parity: parity.dropFirst(), cache: cache)
					let toReturn = results?.map({ leadingString + $0 })
					if shouldCache {
						cache.setObject(NSString(string: toReturn?.joined(separator: ";") ?? ""), forKey: cacheKey)
					}
					return toReturn
				}
				
				var toReturn = [String]()
				let branchAString = String(string.replacingCharacters(in: index..<string.index(after: index), with: "#"))
				let branchBString = String(string.replacingCharacters(in: index..<string.index(after: index), with: "."))
				if let branchA = search(string: branchAString, parity: parity, cache: cache), !branchA.isEmpty {
					toReturn.append(contentsOf: branchA)
				}
				if let branchB = search(string: branchBString, parity: parity, cache: cache), !branchB.isEmpty {
					toReturn.append(contentsOf: branchB)
				}
				if shouldCache {
					cache.setObject(NSString(string: toReturn.joined(separator: ";")), forKey: cacheKey)
				}
				return toReturn
			}
		}
		
		if shouldCache {
			cache.setObject(NSString(string: ""), forKey: cacheKey)
		}
		return nil
	}
	
	func part1() async -> Any {
		let cache = NSCache<NSString, NSString>()
		return data.components(separatedBy: .newlines).map({ possibleArrangements(for: $0, unfold: false, cache: cache) }).sum()
	}
	
	func part2() async -> Any {
//		let lines = data.components(separatedBy: .newlines)
//			
//		let cache = NSCache<NSString, NSString>()
//		cache.evictsObjectsWithDiscardedContent = true
//		cache.countLimit = 200000
//		return await withTaskGroup(of: Int.self, returning: Int.self) { group in
//			for (chunkIndex, chunk) in lines.chunks(ofCount: max(lines.count / 10, 1)).enumerated() {
//				group.addTask {
//					var total = 0
//					for (index, line) in chunk.enumerated() {
//						total += possibleArrangements(for: line, unfold: true, cache: cache)
//						print("\(index + 1)/\(chunk.count) - chunk \(chunkIndex)")
////						cache.removeAllObjects()
//					}
//					return total
//				}
//			}
//			
//			var results = 0
//			for await result in group {
//				results += result
//			}
//			
//			return results
//		}
//			data.components(separatedBy: .newlines).map({ possibleArrangements(for: $0, unfold: true) }).sum()
		
		return 0
	}
}
