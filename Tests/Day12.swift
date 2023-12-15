import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day12Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = """
		?###???????? 3,2,1
		???.### 1,1,3
		.??..??...?##. 1,1,3
		?#?#?#?#?#?#?#? 1,3,1,6
		????.#...#... 4,1,1
		????.######..#####. 1,6,5
		"""
	
	func testPart1() async throws {
		let challenge = Day12(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 21)
	}
	
	func testPart2() async throws {
		let challenge = Day12(data: testData)
		let result = await challenge.part2() as? Int
		XCTAssertEqual(result, 525152)
	}
}
