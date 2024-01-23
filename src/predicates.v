fn opposite_color(color Color) Color {
	if color == .black {
		return Color.white
	} else if color == .white {
		return Color.black
	}
	return Color.not_set
}

fn origin_index_6_row(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return piece.coords.y_coord == 6
}

fn origin_index_1_row(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return piece.coords.y_coord == 1
}

fn within_board(absolute_destination_coords Coords) bool {
	return absolute_destination_coords.x_coord >= 0
		&& absolute_destination_coords.x_coord < game_board_dimension
		&& absolute_destination_coords.y_coord >= 0
		&& absolute_destination_coords.y_coord < game_board_dimension
}

fn destination_no_capture(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].color != opposite_color(piece.color)
}

fn all_conditions_met(game_board [][]Piece, piece Piece, absolute_destination_coords Coords, conditions []fn ([][]Piece, Piece, Coords) bool) bool {
	for condition in conditions {
		if condition(game_board, piece, absolute_destination_coords) == false {
			return false
		}
	}
	return true
}

fn destination_capture(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].color == opposite_color(piece.color)
}

fn destination_no_same_color(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].color != piece.color
}

fn only_one(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	return true
}

fn last_legal_was_capture(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	if piece.legal_moves.len == 0 {
		return false
	}
	last_legal_coords := piece.legal_moves[piece.legal_moves.len - 1]
	if game_board[last_legal_coords.y_coord][last_legal_coords.x_coord].color == .white
		|| game_board[last_legal_coords.y_coord][last_legal_coords.x_coord].color == .black {
		return true
	}
	return false
}

fn cant_capture_king(game_board [][]Piece, piece Piece, absolute_destination_coords Coords) bool {
	if game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].shape == .king {
		return false
	}
	return true
}

fn any_condition_met(game_board [][]Piece, piece Piece, absolute_destination_coords Coords, conditions []fn ([][]Piece, Piece, Coords) bool) bool {
	for condition in conditions {
		if condition(game_board, piece, absolute_destination_coords) == true {
			return true
		}
	}
	return false
}
