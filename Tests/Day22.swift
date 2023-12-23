import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day22Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = #"""
		1,0,1~1,2,1
		0,0,2~2,0,2
		0,2,3~2,2,3
		0,0,4~0,2,4
		2,0,5~2,2,5
		0,1,6~2,1,6
		1,1,8~1,1,9
		"""#
	
	func testPart1() async throws {
		let challenge = Day22(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 5)
	}
	
	func testPart2() async throws {
		let challenge = Day22(data: testData)
		let result = await challenge.part2() as? Int
		XCTAssertEqual(result, 7)
	}
}
