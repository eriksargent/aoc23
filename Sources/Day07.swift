import Algorithms
import Foundation
import RegexBuilder
import AppUtils


struct Day07: AdventDay {
	// Save your data in a corresponding text file in the `Data` directory.
	var data: String
	static var consideringJokers = false

	enum HandType: Int, Equatable, Comparable {
		static func < (lhs: Self, rhs: Self) -> Bool {
			return lhs.rawValue < rhs.rawValue
		}

		case highCard
		case onePair
		case twoPair
		case threeOfAKind
		case fullHouse
		case fourOfAKind
		case fiveOfAKind

		static func type(from cards: [Card], jokers: Int = 0) -> HandType? {
			guard cards.count + jokers == 5 else { return nil }

			let unique = Set(cards)

			switch unique.count {
			case 0: return .fiveOfAKind
			case 1: return .fiveOfAKind
			case 2:
				let numFirst = cards.filter({ $0 == cards[0] }).count
				if numFirst == 1 || numFirst + jokers == 4 {
					return .fourOfAKind
				}
				else {
					return .fullHouse
				}
			case 3:
				let counts = unique.map({ unique in cards.filter({ $0 == unique }).count }).sorted()
				if counts == [1, 2, 2] {
					return .twoPair
				}
				else if counts == [1, 1, 3] {
					return .threeOfAKind
				}
				else if (counts == [1, 1, 1] && jokers == 2) || (counts == [1, 1, 2] && jokers == 1) {
					return .threeOfAKind
				}
				else {
					fatalError()
				}
			case 4:
				return .onePair
			default: return .highCard
			}
		}
	}

	enum Card: Int, Equatable, CustomStringConvertible {
		case ace = 14
		case king = 13
		case queen = 12
		case jack = 11
		case ten = 10
		case nine = 9
		case eight = 8
		case seven = 7
		case six = 6
		case five = 5
		case four = 4
		case three = 3
		case two = 2

		static func < (lhs: Self, rhs: Self) -> Bool {
			if Day07.consideringJokers {
				if lhs == .jack {
					return true
				}
				else if rhs == .jack {
					return false
				}
			}
			return lhs.rawValue < rhs.rawValue
		}

		static func card(from character: Character) -> Card? {
			switch character {
			case "A" : return .ace
			case "K" : return .king
			case "Q" : return .queen
			case "J" : return .jack
			case "T" : return .ten
			case "9" : return .nine
			case "8" : return .eight
			case "7" : return .seven
			case "6" : return .six
			case "5" : return .five
			case "4" : return .four
			case "3" : return .three
			case "2" : return .two
			default: return nil
			}
		}

		var description: String {
			switch self {
			case .ace: return "A"
			case .king: return "K"
			case .queen: return "Q"
			case .jack: return "J"
			case .ten: return "T"
			case .nine: return "9"
			case .eight: return "8"
			case .seven: return "7"
			case .six: return "6"
			case .five: return "5"
			case .four: return "4"
			case .three: return "3"
			case .two: return "2"
			}
		}
	}

	struct Hand: Comparable, Equatable, CustomStringConvertible {
		var type: HandType
		var cards: [Card]
		var bid: Int

		static func < (lhs: Self, rhs: Self) -> Bool {
			if lhs.type == rhs.type, let (lcard, rcard) = zip(lhs.cards, rhs.cards).first(where: { $0.0 != $0.1 }) {
				return lcard < rcard
			}
			else {
				return lhs.type < rhs.type
			}
		}

		static func parse(_ string: String) -> Hand? {
			let comps = string.components(separatedBy: .whitespaces)
			guard comps.count == 2, let bid = Int(comps[1]) else { return nil }

			let cards = comps[0].compactMap(Card.card(from:))
			guard let type = HandType.type(from: cards) else { return nil }

			return Hand(type: type, cards: cards, bid: bid)
		}
		
		static func parseWithJokers(_ string: String) -> Hand? {
			let comps = string.components(separatedBy: .whitespaces)
			guard comps.count == 2, let bid = Int(comps[1]) else { return nil }
			
			let cards = comps[0].compactMap(Card.card(from:))
			let jokers = cards.filter({ $0 == .jack }).count
			let filteredCards = cards.filter({ $0 != .jack })
			guard let type = HandType.type(from: filteredCards, jokers: jokers) else { return nil }
			
			return Hand(type: type, cards: cards, bid: bid)
		}

		var description: String {
			"\(String(describing: type)) - \(cards.map(\.description).joined()) - \(bid)"
		}
	}

	func part1() -> Any {
		Self.consideringJokers = false
		let hands = data.components(separatedBy: .newlines).compactMap(Hand.parse(_:))
		let sorted = hands.sorted()
		
		return sorted.map(\.bid).enumerated().map({ ($0 + 1) * $1 }).sum()
	}

	func part2() -> Any {
		Self.consideringJokers = true
		let hands = data.components(separatedBy: .newlines).compactMap(Hand.parseWithJokers(_:))
		let sorted = hands.sorted()
		
		return sorted.map(\.bid).enumerated().map({ ($0 + 1) * $1 }).sum()
	}
}
