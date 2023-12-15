import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day14Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = """
		O....#....
		O.OO#....#
		.....##...
		OO.#O....O
		.O.....O#.
		O.#..O.#.#
		..O..#O..O
		.......O..
		#....###..
		#OO..#....
		"""
	
	func testPart1() async throws {
		let challenge = Day14(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 136)
	}
	
	func testPart2() async throws {
		let challenge = Day14(data: testData)
		let result = await challenge.part2() as? Int
		XCTAssertEqual(result, 64)
	}
}
