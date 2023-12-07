import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day06: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	func parseRaces(combine: Bool = false) -> [(time: Int, distance: Int)] {
		let comps = data.components(separatedBy: .newlines)
		guard comps.count == 2 else { return [] }
		
		var times = comps[0].components(separatedBy: .whitespaces).compactMap(Int.init)
		var dists = comps[1].components(separatedBy: .whitespaces).compactMap(Int.init)
		
		if combine, let cTimes = Int(times.map(String.init).joined()), let cDists = Int(dists.map(String.init).joined()) {
			times = [cTimes]
			dists = [cDists]
		}
		
		return zip(times, dists).map({ (time: $0, distance: $1) })
	}
	
	func options(for time: Int, distance: Int) -> Int {
		let a = -1.0
		let b = Double(time)
		let c = Double(-distance)
		let sterm = sqrt(b * b - 4 * a * c)
		let den = 2.0 * a
		let rangeStart = ((-b + sterm) / den).rounded(.down) + 1
		let rangeEnd = ((-b - sterm) / den).rounded(.up) - 1
		return Int(rangeEnd - rangeStart + 1)
	}
	
	func part1() -> Any {
		let races = parseRaces()
		return races.map({ options(for: $0.time, distance: $0.distance) }).reduce(1, *)
	}
	
	func part2() -> Any {
		let races = parseRaces(combine: true)
		return races.map({ options(for: $0.time, distance: $0.distance) }).reduce(1, *)
	}
}
