import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day21Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = #"""
		...........
		.....###.#.
		.###.##..#.
		..#.#...#..
		....#.#....
		.##..S####.
		.##..#...#.
		.......##..
		.##.#.####.
		.##..##.##.
		...........
		"""#
	
	func testPart1() async throws {
		let challenge = Day21(data: testData, steps: 6)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 16)
	}
	
	func testPart2() async throws {
//		var challenge = Day21(data: testData, steps: 100)
//		var result = await challenge.part2() as? Int
//		XCTAssertEqual(result, 6536)
		
		var challenge = Day21(data: testData, steps: 500)
		var result = await challenge.part2() as? Int
		XCTAssertEqual(result, 167004)
	}
}
