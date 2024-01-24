module main

import gg

enum SelectionState {
	not_set            = -1
	origin_coords
	destination_coords
}

enum Color {
	not_set = -1
	white
	black
}

struct RelativeCoords {
	mut:
	relative_coords  Coords
	conditions       []fn ([][]Piece, Piece, Coords) bool
	break_conditions []fn ([][]Piece, Piece, Coords) bool
	modifiers        []string
}

struct Coords {
	mut:
	y_coord int
	x_coord int
}

fn (a Coords) + (b Coords) Coords {
	return Coords{
		y_coord: (a.y_coord + b.y_coord)
		x_coord: (a.x_coord + b.x_coord)
	}
}

enum Shape {
	not_set      = -4
	empty_square = -1
	rook         = 0
	knight       = 1
	bishop       = 2
	queen        = 3
	king         = 4
	pawn         = 5
}

struct Piece {
	color Color
	mut:
	shape       Shape
	coords      Coords
	legal_moves []Coords
	has_moved   bool     // only needed for king and rook
	last_move   []Coords // only needed for pawns for En Passant
	map_key     string
}

fn move_piece(mut game_board [][]Piece, mut origin_piece Piece, destination_piece Piece) {
	origin_coords := origin_piece.coords
	origin_piece.coords = destination_piece.coords
	game_board[destination_piece.coords.y_coord][destination_piece.coords.x_coord] = origin_piece
	game_board[origin_coords.y_coord][origin_coords.x_coord] = Piece{
		shape: .empty_square
		coords: origin_coords
	}
}

fn coords_in_legal_moves(legal_moves []Coords, coords Coords) bool {
	mut ret := false
	for legal_move in legal_moves {
		if legal_move.y_coord == coords.y_coord && legal_move.x_coord == coords.x_coord {
			ret = true
		}
	}
	return ret
}

fn set_legal_moves_game_board(mut legal_moves_game_board [][]bool, legal_moves []Coords) {
	for y_coord, mut row in legal_moves_game_board {
		for x_coord, mut cell in row {
			cell = false
		}
	}
	for legal_move in legal_moves {
		legal_moves_game_board[legal_move.y_coord][legal_move.x_coord] = true
	}
}

fn (mut app App) handle_coords(coords Coords) {
	if app.selection_state == .origin_coords
		&& app.game_board[coords.y_coord][coords.x_coord].color == app.current_player {
			app.origin_coords = coords
			app.selection_state = .destination_coords
			set_legal_moves(mut app.game_board, mut app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord])
			set_legal_moves_game_board( mut app.legal_moves_game_board, app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord].legal_moves)
		} else if app.selection_state == .destination_coords {
			if !coords_in_legal_moves(app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord].legal_moves,
									  coords) || app.game_board[coords.y_coord][coords.x_coord].shape == .king {
										  app.selection_state = .origin_coords
										  return
									  }
			app.destination_coords = coords
			move_piece(mut app.game_board, mut app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord],
					   app.game_board[app.destination_coords.y_coord][app.destination_coords.x_coord])
			app.current_player = opposite_color(app.current_player)
			app.selection_state = .origin_coords
		}
}

fn (mut app App) get_legal_moves(mut game_board [][]Piece, mut piece Piece) []Coords {
	mut legal_moves := []Coords{}

	for relative_coords in relative_coords_map[piece.map_key] {
		mut absolute_destination_coords := piece.coords + relative_coords.relative_coords
		for ; within_board(absolute_destination_coords)
			&& all_conditions_met(game_board, piece, absolute_destination_coords, relative_coords.conditions); absolute_destination_coords =
			absolute_destination_coords + relative_coords.relative_coords {
				legal_moves << absolute_destination_coords
				if any_condition_met(game_board, piece, absolute_destination_coords,
									 relative_coords.break_conditions)
				{
					break
				}
			}
	}
	return legal_moves
}

fn set_legal_moves(mut game_board [][]Piece, mut piece Piece) {
	// mut local_piece := piece
	piece.legal_moves = [] // clear the legal moves first before generating new ones

	for relative_coords in relative_coords_map[piece.map_key] {
		mut absolute_destination_coords := piece.coords + relative_coords.relative_coords
		for ; within_board(absolute_destination_coords)
			&& all_conditions_met(game_board, piece, absolute_destination_coords, relative_coords.conditions); absolute_destination_coords =
			absolute_destination_coords + relative_coords.relative_coords {
				piece.legal_moves << absolute_destination_coords
				if any_condition_met(game_board, piece, absolute_destination_coords,
									 relative_coords.break_conditions)
				{
					break
				}
			}
	}
}

struct App {
	mut:
	gg                     &gg.Context = unsafe { nil }
	image_database         map[string]gg.Image
	game_board             [][]Piece
	selection_state        SelectionState
	current_player         Color
	origin_coords          Coords
	destination_coords     Coords
	legal_moves_game_board [][]bool
	who_in_check Color
	winner Color
}
