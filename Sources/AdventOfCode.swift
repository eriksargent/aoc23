import ArgumentParser

// Add each new day implementation to this array:
let allChallenges: [any AdventDay] = [
	Day01(),
	Day02(),
	Day03(),
	Day04(),
	Day05(),
	Day06(),
	Day07(),
	Day08(),
	Day09(),
	Day10(),
	Day11(),
	Day12(),
	Day13(),
	Day14(),
	Day15(),
	Day16(),
	Day17()
]

@main
struct AdventOfCode: AsyncParsableCommand {
	@Argument(help: "The day of the challenge. For December 1st, use '1'.")
	var day: Int?
	
	@Flag(help: "Benchmark the time taken by the solution")
	var benchmark: Bool = false
	
	@Flag(help: "Run all days in order")
	var all: Bool = false
	
	/// The selected day, or the latest day if no selection is provided.
	var selectedChallenge: any AdventDay {
		get throws {
			if let day {
				if let challenge = allChallenges.first(where: { $0.day == day }) {
					return challenge
				} else {
					throw ValidationError("No solution found for day \(day)")
				}
			} else {
				return latestChallenge
			}
		}
	}
	
	/// The latest challenge in `allChallenges`.
	var latestChallenge: any AdventDay {
		allChallenges.max(by: { $0.day < $1.day })!
	}
	
	func run(part: () async throws -> Any, named: String) async -> Duration {
		var result: Result<Any, Error> = .success("<unsolved>")
		let timing = await ContinuousClock().measure {
			do {
				result = .success(try await part())
			} catch {
				result = .failure(error)
			}
		}
		switch result {
		case .success(let success):
			print("\(named): \(success)")
		case .failure(let failure):
			print("\(named): Failed with error: \(failure)")
		}
		return timing
	}
	
	func run() async throws {
		if all {
			var allTimings = [(day: Int, timing1: Duration, timing2: Duration)]()
			for day in allChallenges {
				let (timing1, timing2) = await execute(challenge: day)
				allTimings.append((day.day, timing1, timing2))
			}
			
			print("|Day|Part 1|Part 2|")
			print("|---|------|------|")
			for (day, timing1, timing2) in allTimings {
				print("|\(day)|\(timing1))|\(timing2)|")
			}
		}
		else {
			let challenge = try selectedChallenge
			await execute(challenge: challenge)
		}
	}
	
	@discardableResult
	func execute(challenge: any AdventDay) async -> (Duration, Duration) {
		print("Executing Advent of Code challenge \(challenge.day)...")
		
		let timing1 = await run(part: challenge.part1, named: "Part 1")
		let timing2 = await run(part: challenge.part2, named: "Part 2")
		
		print("Part 1 took \(timing1), part 2 took \(timing2).")
		
		return (timing1, timing2)
	}
}
