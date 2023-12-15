import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day12Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = """
		???.### 1,1,3
		.??..??...?##. 1,1,3
		?#?#?#?#?#?#?#? 1,3,1,6
		????.#...#... 4,1,1
		????.######..#####. 1,6,5
		?###???????? 3,2,1
		"""
	
	func testPart1() async throws {
		let timing = await ContinuousClock().measure {
			let challenge = Day12(data: testData)
			var result = await challenge.part1() as? Int
			XCTAssertEqual(result, 21)
			result = await Day12(data: ".....???.### 1,1,3").part1() as? Int
			XCTAssertEqual(result, 1)
			result = await Day12(data: ".....###.??? 3,1,1").part1() as? Int
			XCTAssertEqual(result, 1)
		}
		print("Part 1 tests: \(timing)")
	}
	
	func testPart2() async throws {
		let timing = await ContinuousClock().measure {
			let challenge = Day12(data: testData)
			var result = await challenge.part2() as? Int
			XCTAssertEqual(result, 525152)
			result = await Day12(data: "???.### 1,1,3").part2() as? Int
			XCTAssertEqual(result, 1)
			result = await Day12(data: ".??..??...?##. 1,1,3").part2() as? Int
			XCTAssertEqual(result, 16384)
			result = await Day12(data: "?#?#?#?#?#?#?#? 1,3,1,6").part2() as? Int
			XCTAssertEqual(result, 1)
			result = await Day12(data: "????.#...#... 4,1,1").part2() as? Int
			XCTAssertEqual(result, 16)
			result = await Day12(data: "????.######..#####. 1,6,5").part2() as? Int
			XCTAssertEqual(result, 2500)
			result = await Day12(data: "?###???????? 3,2,1").part2() as? Int
			XCTAssertEqual(result, 506250)
		}
		print("Part 2 tests: \(timing)")
	}
}
