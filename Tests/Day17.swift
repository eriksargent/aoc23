import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day17Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = #"""
		2413432311323
		3215453535623
		3255245654254
		3446585845452
		4546657867536
		1438598798454
		4457876987766
		3637877979653
		4654967986887
		4564679986453
		1224686865563
		2546548887735
		4322674655533
		"""#
	
	func testPart1() async throws {
		let challenge = Day17(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 102)
		
		let result2 = await Day17(
			data:
				"""
				11599
				99199
				99199
				99199
				99111
				""")
			.part1() as? Int
		XCTAssertNotEqual(result2, 20)
	}
	
	func testPart2() async throws {
		let challenge = Day17(data: testData)
		let result = await challenge.part2() as? Int
		XCTAssertEqual(result, 94)
	}
}
