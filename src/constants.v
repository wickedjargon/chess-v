module main

const game_board_dimension = 8
const empty_game_board = [][]Piece{len: game_board_dimension, cap: game_board_dimension, init: []Piece{len: game_board_dimension, cap: game_board_dimension, init: Piece{}}}

const relative_coords_map := {
	'black_rook':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'white_rook':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'black_knight': [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 2
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 2
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -2
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -2
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
	]
	'white_knight': [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 2
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 2
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -2
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -2
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -2
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
	]
	'black_bishop': [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'white_bishop': [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'black_queen':  [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'white_queen':  [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [last_legal_was_capture]
		},
	]
	'black_king':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
	]
	'white_king':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: 1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 0
				x_coord: -1
			}
			conditions: [destination_no_same_color]
			break_conditions: [only_one]
		},
	]
	'black_pawn':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 2
				x_coord: 0
			}
			conditions: [destination_no_same_color, origin_index_1_row,
				destination_no_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 0
			}
			conditions: [destination_no_same_color, destination_no_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: 1
			}
			conditions: [destination_no_same_color, destination_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: 1
				x_coord: -1
			}
			conditions: [destination_no_same_color, destination_capture]
			break_conditions: [only_one]
		},
	]
	'white_pawn':   [
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -2
				x_coord: 0
			}
			conditions: [destination_no_same_color, origin_index_6_row,
				destination_no_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 0
			}
			conditions: [destination_no_same_color, destination_no_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: -1
			}
			conditions: [destination_no_same_color, destination_capture]
			break_conditions: [only_one]
		},
		RelativeCoords{
			relative_coords: Coords{
				y_coord: -1
				x_coord: 1
			}
			conditions: [destination_no_same_color, destination_capture]
			break_conditions: [only_one]
		},
	]
}
