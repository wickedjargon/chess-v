// NOTE: command used to increase image sizes: `mogrify -filter point -resize 400% *.png` (an imagemagick command)
//

import gg
import os

fn (mut app App) init_images_wrapper() {
	app.init_images() or { panic(err) }
}

fn (mut app App) init_images_pieces(shapes []string, color string) ! {
	for shape in shapes {
		app.image_database['${color}_${shape}'] = app.gg.create_image(os.resource_abs_path('./assets/${color}_${shape}.png'))!
	}
}

fn (mut app App) init_images() ! {
	shapes := ['rook', 'knight', 'bishop', 'queen', 'king', 'pawn']
	app.init_images_pieces(shapes, 'black')!
	app.init_images_pieces(shapes, 'white')!
	app.image_database['game_board_image'] = app.gg.create_image(os.resource_abs_path('./assets/game_board_image.png'))!
	app.image_database['circle'] = app.gg.create_image(os.resource_abs_path('./assets/circle.png'))!
}

fn (app App) draw_legal_moves() {
	for y_coord, rows in app.legal_moves_game_board {
		for x_coord, piece in rows {
			if piece.shape == .legal_move && app.game_board[y_coord][x_coord].shape != .king {
				piece_image := app.image_database['circle'] or { panic('line 40') }
				app.draw_piece_at_coordinate(piece_image, x_coord, y_coord)
			}
		}
	}
}

fn frame(app &App) {
	app.gg.begin()
	app.draw_game_board()
	app.draw_pieces()
	if app.selection_state == .destination_coords {
		app.draw_legal_moves()
	}
	app.gg.end()
}

fn (app App) draw_game_board() {
	game_board_image := app.image_database['game_board_image'] or { panic('line 32') }
	app.gg.draw_image(0.0, 0.0, f32(game_board_image.width), f32(game_board_image.height),
		game_board_image)
}

fn (app App) draw_pieces() {
	for y_coord, rows in app.game_board {
		for x_coord, piece in rows {
			if piece.shape != .empty_square {
				piece_image := app.image_database[piece.map_key] or { panic('line 40') }
				app.draw_piece_at_coordinate(piece_image, x_coord, y_coord)
			}
		}
	}
}

fn (app App) draw_piece_at_coordinate(piece gg.Image, x int, y int) {
	game_board_image := app.image_database['game_board_image'] or { panic('line 48') }
	square_width := f32(game_board_image.width) / f32(game_board_dimension)
	square_height := f32(game_board_image.height) / f32(game_board_dimension)

	x_coord := square_width * f32(x) + (square_width - f32(piece.width)) / 2.0
	y_coord := square_height * f32(y) + (square_height - f32(piece.height)) / 2.0

	app.gg.draw_image(x_coord, y_coord, f32(piece.width), f32(piece.height), piece)
}

fn place_piece_new_game(mut game_board [][]Piece, piece Piece, destination_coords Coords) {
	destination_piece := game_board[destination_coords.y_coord][destination_coords.x_coord]
	if destination_piece.shape == .empty_square {
		mut local_piece := piece
		local_piece.coords = destination_coords
		game_board[destination_coords.y_coord][destination_coords.x_coord] = local_piece
	}
}

fn opposite_color(color Color) Color {
	if color == .black {
		return Color.white
	} else if color == .white {
		return Color.black
	}
	return Color.not_set
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

fn (mut app App) set_legal_moves_game_board(legal_moves []Coords) {
	for y_coord, mut row in app.legal_moves_game_board {
		for x_coord, mut piece in row {
			piece.shape = .illegal_move
		}
	}
	for legal_move in legal_moves {
		app.legal_moves_game_board[legal_move.y_coord][legal_move.x_coord].shape = .legal_move
		app.legal_moves_game_board[legal_move.y_coord][legal_move.x_coord].coords = Coords{
			y_coord: legal_move.y_coord
			x_coord: legal_move.x_coord
		}
	}
}

fn (mut app App) handle_coords(coords Coords) {
	if app.selection_state == .origin_coords
		&& app.game_board[coords.y_coord][coords.x_coord].color == app.current_player {
		app.origin_coords = coords
		app.selection_state = .destination_coords
		app.set_legal_moves_game_board(app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord].legal_moves)
	} else if app.selection_state == .destination_coords {
		if !coords_in_legal_moves(app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord].legal_moves,
			coords) || app.game_board[coords.y_coord][coords.x_coord].shape == .king {
			app.selection_state = .origin_coords
			return
		}
		app.destination_coords = coords
		move_piece(mut app.game_board, mut app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord],
			app.game_board[app.destination_coords.y_coord][app.destination_coords.x_coord])
		app.set_legal_moves_wrapper(mut app.game_board)
		app.current_player = opposite_color(app.current_player)
		app.selection_state = .origin_coords
	}
}

fn click(x f32, y f32, button gg.MouseButton, mut app App) {
	game_board := app.image_database['game_board_image'] or { panic('line 108') }
	game_board_width := game_board.width
	game_board_height := game_board.height

	// Check if the click is within the chessgame_board bounds
	if x < 0.0 || x > f32(game_board_width) || y < 0.0 || y > f32(game_board_height) {
		return
	}

	// Calculate the square indices based on the clicked coordinates
	square_size_y := f32(game_board_height) / f32(game_board_dimension)
	square_size_x := f32(game_board_width) / f32(game_board_dimension)

	y_coord := int(y / square_size_y)
	x_coord := int(x / square_size_x)

	app.handle_coords(Coords{y_coord, x_coord})
}

fn on_event(e &gg.Event, mut app App) {
	if e.typ == .key_up {
		match e.key_code {
			.r { app.new_game() }
			.q { app.gg.quit() }
			else {}
		}
	}
}

const game_board_dimension = 8
const empty_game_board = [][]Piece{len: game_board_dimension, cap: game_board_dimension, init: []Piece{len: game_board_dimension, cap: game_board_dimension, init: Piece{}}}

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

// struct Move {
// 	coords Coords
// 	timestamp
// }

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
	illegal_move = -3
	legal_move   = -2
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

fn get_starting_pieces(color Color) []Piece {
	mut pieces := []Piece{}
	for i in 0 .. 5 {
		pieces << Piece{
			shape: unsafe { Shape(i) }
			color: color
		}
	}
	for i := 2; i >= 0; i-- {
		pieces << Piece{
			shape: unsafe { Shape(i) }
			color: color
		}
	}
	return pieces
}

fn set_pieces_new_game(mut game_board [][]Piece) {
	// setup the back-rank pieces
	black_pieces := get_starting_pieces(Color.black)
	mut y_coord := 0
	for x_coord, piece in black_pieces {
		place_piece_new_game(mut game_board, piece, Coords{ y_coord: y_coord, x_coord: x_coord })
	}
	y_coord = 7
	white_pieces := get_starting_pieces(Color.white)
	for x_coord, piece in white_pieces {
		place_piece_new_game(mut game_board, piece, Coords{ y_coord: y_coord, x_coord: x_coord })
	}

	// setup the pawn pieces
	y_coord = 1
	black_pawn := Piece{
		shape: .pawn
		color: .black
	}
	for x_coord in 0 .. game_board_dimension {
		place_piece_new_game(mut game_board, black_pawn, Coords{ y_coord: y_coord, x_coord: x_coord })
	}
	y_coord = 6
	white_pawn := Piece{
		shape: .pawn
		color: .white
	}
	for x_coord in 0 .. game_board_dimension {
		place_piece_new_game(mut game_board, white_pawn, Coords{ y_coord: y_coord, x_coord: x_coord })
	}
}

fn set_empty_pieces(mut game_board [][]Piece) {
	for y_coord in 0 .. game_board_dimension {
		for x_coord in 0 .. game_board_dimension {
			game_board[y_coord][x_coord] = Piece{
				shape: .empty_square
				coords: Coords{
					y_coord: y_coord
					x_coord: x_coord
				}
			}
		}
	}
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

fn (mut app App) set_legal_moves(mut game_board [][]Piece, mut piece Piece) {
	// mut local_piece := piece
	relative_coords_map := {
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
	piece.legal_moves = [] // clear the legal moves first before generating new ones

	for relative_coords in relative_coords_map[piece.map_key] {
		mut absolute_destination_coords := piece.coords + relative_coords.relative_coords
		for ; within_board(absolute_destination_coords)
			&& all_conditions_met(game_board, piece, absolute_destination_coords, relative_coords.conditions); absolute_destination_coords =
			absolute_destination_coords + relative_coords.relative_coords {
			piece.legal_moves << absolute_destination_coords
				if game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].shape == .king {
					app.who_in_check = game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].color
					app.set_legal_moves(mut game_board, mut game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord])
					if game_board[absolute_destination_coords.y_coord][absolute_destination_coords.x_coord].legal_moves.len == 0 {
						app.winner = piece.color
					}
				}
			if any_condition_met(game_board, piece, absolute_destination_coords,
				relative_coords.break_conditions)
			{
				break
			}
		}
	}
}

fn any_condition_met(game_board [][]Piece, piece Piece, absolute_destination_coords Coords, conditions []fn ([][]Piece, Piece, Coords) bool) bool {
	for condition in conditions {
		if condition(game_board, piece, absolute_destination_coords) == true {
			return true
		}
	}
	return false
}

fn (mut app App) set_legal_moves_wrapper(mut game_board [][]Piece) {
	for y_coord, mut row in game_board {
		for x_coord, mut piece in row {
			if piece.shape != .empty_square {
				app.set_legal_moves(mut game_board, mut piece)
			}
		}
	}
}

fn set_map_keys(mut game_board [][]Piece) {
	for y_coord, mut row in game_board {
		for x_coord, mut piece in row {
			piece.map_key = '${piece.color}_${piece.shape}'
		}
	}
}

fn (mut app App) new_game() {
	app.selection_state = .origin_coords
	app.current_player = .white
	app.game_board = [][]Piece{len: 8, cap: 8, init: []Piece{len: 8, cap: 8, init: Piece{}}}
	app.legal_moves_game_board = [][]Piece{len: 8, cap: 8, init: []Piece{len: 8, cap: 8, init: Piece{
		shape: .illegal_move
	}}}
	set_empty_pieces(mut app.game_board)
	set_pieces_new_game(mut app.game_board)
	set_map_keys(mut app.game_board)
	app.set_legal_moves_wrapper(mut app.game_board)
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
	legal_moves_game_board [][]Piece
	who_in_check Color
	winner Color
}

fn main() {
	mut app := &App{}
	app.new_game()
	app.gg = gg.new_context(
		user_data: app
		window_title: 'Chess'
		init_fn: app.init_images_wrapper
		width: 1000
		height: 1000
		click_fn: click
		frame_fn: frame
		event_fn: on_event
	)
	app.gg.run()
}
