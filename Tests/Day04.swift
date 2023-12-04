import XCTest

@testable import AdventOfCode

// Make a copy of this file for every day to ensure the provided smoke tests
// pass.
final class Day04Tests: XCTestCase {
	// Smoke test data provided in the challenge question
	let testData = """
		467..114..
		...*......
		..35..633.
		......#...
		617*......
		.....+.58.
		..592.....
		......755.
		...$.*....
		.664.598..
		"""
	
	func testPart1() throws {
		let challenge = Day04(data: testData)
		XCTAssertEqual(String(describing: challenge.part1()), "4361")
	}

	func testPart2() throws {
		var challenge = Day04(data: testData)
		XCTAssertEqual(String(describing: challenge.part2()), "467835")
		
		let data2 = """
			12.......*..
			+.........34
			.......-12..
			..78........
			..*....60...
			78..........
			.......23...
			....90*12...
			............
			2.2......12.
			.*.........*
			1.1.......56
			"""
		
		challenge = Day04(data: data2)
		XCTAssertEqual(String(describing: challenge.part2()), "6756")
		
		let data3 = """
			12.......*..
			+.........34
			.......-12..
			..78........
			..*....60...
			78.........9
			.5.....23..$
			8...90*12...
			............
			2.2......12.
			.*.........*
			1.1..503+.56
			"""
		
		challenge = Day04(data: data3)
		XCTAssertEqual(String(describing: challenge.part2()), "6756")
	}
}
