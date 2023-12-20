import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day20Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = #"""
		broadcaster -> a
		%a -> inv, con
		&inv -> b
		%b -> con
		&con -> output
		"""#
	
	func testPart1() async throws {
		let challenge = Day20(data: testData)
		let result = await challenge.part1() as? Int
		XCTAssertEqual(result, 11687500)
	}
	
	func testPart2() async throws {
	}
}
