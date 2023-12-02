import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day01: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	enum CubeColor: String {
		case red
		case green
		case blue
	}
	
	struct Game: CustomStringConvertible {
		var id: Int
		var draws: [Draw]
		
		struct Draw: CustomStringConvertible {
			var cubes: [Cube]
			
			struct Cube: CustomStringConvertible {
				var count: Int
				var cube: CubeColor
				
				var description: String {
					"\(count) \(cube.rawValue)"
				}
			}
			
			var description: String {
				cubes.map(\.description).joined(separator: ", ")
			}
			
			func all(_ color: CubeColor) -> Int {
				cubes.filter(where: \.cube, is: color).map(\.count).sum()
			}
			
			static func parse(from string: String) -> Draw? {
				let countRef = Reference(Int.self)
				let colorRef = Reference(CubeColor.self)
				let regex = Regex {
					TryCapture(as: countRef) {
						OneOrMore(.digit)
					} transform: { match in
						Int(match)
					}
					" "
					TryCapture(as: colorRef) {
						OneOrMore(.word)
					} transform: { match in
						CubeColor(rawValue: String(match))
					}
				}
				
				let cubes = string.components(separatedBy: ",").compactMap({ $0.firstMatch(of: regex) }).map({ Cube(count: $0[countRef], cube: $0[colorRef]) })
				return Draw(cubes: cubes)
			}
		}
		
		var description: String {
			"Game \(id): " + draws.map(\.description).joined(separator: "; ")
		}
		
		static func parse(from string: String) -> Game? {
			let gameNumberRef = Reference(Int.self)
			let drawsRef = Reference(Substring.self)
			let gameNumberRegex = Regex {
				"Game "
				
				TryCapture(as: gameNumberRef) {
					OneOrMore(.digit)
				} transform: { match in
					Int(match)
				}
				": "
				
				Capture(as: drawsRef) {
					OneOrMore(.any)
				}
			}
			
			guard let match = string.firstMatch(of: gameNumberRegex) else { return nil }
			
			let number = match[gameNumberRef]
			let drawsString = match[drawsRef]
			
			let draws = drawsString.components(separatedBy: ";").compactMap(Game.Draw.parse(from:))
			return Game(id: number, draws: draws)
		}
		
		func isPossible(usingRed red: Int, green: Int, blue: Int) -> Bool {
			draws.allSatisfy { draw in
				draw.all(.red) <= red && draw.all(.green) <= green && draw.all(.blue) <= blue
			}
		}
		
		var minimumPossible: (red: Int, green: Int, blue: Int) {
			let red = draws.map({ $0.all(.red) }).max() ?? 0
			let green = draws.map({ $0.all(.green) }).max() ?? 0
			let blue = draws.map({ $0.all(.blue) }).max() ?? 0
			return (red: red, green: green, blue: blue)
		}
		
		var power: Int {
			let minimum = minimumPossible
			return minimum.red * minimum.green * minimum.blue
		}
	}
	
	func parseGames() -> [Game] {
		let lines = data.components(separatedBy: .newlines).filter({ $0 != "" })
		let games = lines.compactMap(Game.parse(from:))
		let errors = zip(lines, games.map(\.description)).filter({ $0 != $1 })
		assert(errors.isEmpty)
		return games
	}
	
	func part1() -> Any {
		let games = parseGames()
		
		return games.filter({ $0.isPossible(usingRed: 12, green: 13, blue: 14) }).map(\.id).sum()
	}
	
	func part2() -> Any {
		let games = parseGames()
		
		let powers = games.map(\.power)
		return powers.sum()
	}
}
