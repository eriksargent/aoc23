import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day13Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = """
		#.##..##.
		..#.##.#.
		##......#
		##......#
		..#.##.#.
		..##..##.
		#.#.##.#.

		#...##..#
		#....#..#
		..##..###
		#####.##.
		#####.##.
		..##..###
		#....#..#
		"""
	
	func testPart1() async throws {
		let challenge = Day13(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 405)
	}
	
	func testPart2() async throws {
		let challenge = Day13(data: testData)
		let result = await challenge.part2() as? Int
		XCTAssertEqual(result, 400)
	}
}
