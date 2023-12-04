import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day04: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	
	struct Card {
		let card: Int
		let winning: [Int]
		let numbers: [Int]
		
		var numbersWon: [Int] {
			numbers.filter({ winning.contains($0) })
		}
		
		var points: Int {
			let count = numbersWon.count
			if count == 0 {
				return 0
			}
			return 1 << (count - 1)
		}
		
		init?(from string: String) {
			let cardRef = Reference(Int.self)
			let winningRef = Reference([Int].self)
			let numbersRef = Reference([Int].self)
			let regex = Regex {
				"Card "
				ZeroOrMore(.whitespace)
				TryCapture(as: cardRef, { OneOrMore(.digit) }, transform: { Int($0) })
				":"
				OneOrMore(.whitespace)
				Capture(as: winningRef, {
					OneOrMore {
						OneOrMore(.digit)
						OneOrMore(.whitespace)
					}
				}, transform: {
					$0.components(separatedBy: .whitespaces).compactMap(Int.init)
				})
				"|"
				OneOrMore(.whitespace)
				Capture(as: numbersRef, {
					OneOrMore {
						OneOrMore(.digit)
						ZeroOrMore(.whitespace)
					}
				}, transform: {
					$0.components(separatedBy: .whitespaces).compactMap(Int.init)
				})
			}
			
			guard let match = string.firstMatch(of: regex) else { return nil }
			
			self.card = match[cardRef]
			self.winning = match[winningRef]
			self.numbers = match[numbersRef]
		}
	}
	
	
	func part1() -> Any {
		let cards = data.components(separatedBy: .newlines).compactMap(Card.init(from:))
		var generated = [String]()
#if DEBUG
		for card in cards {
			print("Card \(card.card) is worth \(card.points) with winning numbers \(card.numbersWon)")
			var string = "Card \(pad: card.card, toWidth: cards.count > 100 ? 3 : 1):"
			for num in card.winning {
				string += " \(pad: num, toWidth: 2)"
			}
			string += " |"
			for num in card.numbers {
				string += " \(pad: num, toWidth: 2)"
			}
			generated.append(string)
		}
		assert(generated.joined(separator: "\n") == data)
#endif
		return cards.map(\.points).sum()
	}
	
	func part2() -> Any {
		let cards = data.components(separatedBy: .newlines).compactMap(Card.init(from:))
		var counts = [Int](repeating: 1, count: cards.count)
		
		for (index, card) in cards.enumerated() {
			let winning = card.numbersWon.count
			if winning > 0 {
				let thisCount = counts[index]
				for next in (index + 1)...(index + winning) {
					counts[next] += thisCount
				}
			}
		}
		
		return counts.sum()
	}
}


extension DefaultStringInterpolation {
	mutating func appendInterpolation(pad value: Int, toWidth width: Int, using paddingCharacter: String = " ") {
		appendInterpolation(String(String("\(value)".reversed()).padding(toLength: width, withPad: paddingCharacter, startingAt: 0).reversed()))
	}
}
