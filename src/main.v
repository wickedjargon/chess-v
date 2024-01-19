// NOTE: command used to increase image sizes: `mogrify -filter point -resize 400% *.png` (an imagemagick command)


import gg
import os


fn (mut app App) init_images_wrapper() {
	app.init_images() or { panic(err) }
}

fn (mut app App) init_images() ! {
	app.black_bishop = app.gg.create_image(os.resource_abs_path('../assets/black_bishop.png'))!
	app.black_king = app.gg.create_image(os.resource_abs_path('../assets/black_king.png'))!
	app.black_knight = app.gg.create_image(os.resource_abs_path('../assets/black_knight.png'))!
	app.black_pawn = app.gg.create_image(os.resource_abs_path('../assets/black_pawn.png'))!
	app.black_queen = app.gg.create_image(os.resource_abs_path('../assets/black_queen.png'))!
	app.black_rook = app.gg.create_image(os.resource_abs_path('../assets/black_rook.png'))!
	app.white_bishop = app.gg.create_image(os.resource_abs_path('../assets/white_bishop.png'))!
	app.white_king = app.gg.create_image(os.resource_abs_path('../assets/white_king.png'))!
	app.white_knight = app.gg.create_image(os.resource_abs_path('../assets/white_knight.png'))!
	app.white_pawn = app.gg.create_image(os.resource_abs_path('../assets/white_pawn.png'))!
	app.white_queen = app.gg.create_image(os.resource_abs_path('../assets/white_queen.png'))!
	app.white_rook = app.gg.create_image(os.resource_abs_path('../assets/white_rook.png'))!
	app.game_board_image = app.gg.create_image(os.resource_abs_path('../assets/game_board_image.png'))!
}


fn frame(app &App) {
	app.gg.begin()
	app.draw_game_board()
	app.draw_pieces()
	app.gg.end()
}


fn (app App) draw_game_board() {
	app.gg.draw_image(0.0, 0.0, f32(app.game_board_image.width), f32(app.game_board_image.height),
		app.game_board_image)
}

fn (app App) draw_pieces() {
	for y_coord, rows in app.game_board {
		for x_coord, piece in rows {
			if piece.shape == .rook && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_rook, x_coord, y_coord)
			}
			else if piece.shape == .knight && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_knight, x_coord, y_coord)
			}
			else if piece.shape == .bishop && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_bishop, x_coord, y_coord)
			}
			else if piece.shape == .queen && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_queen, x_coord, y_coord)
			}
			else if piece.shape == .king && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_king, x_coord, y_coord)
			}
			else if piece.shape == .pawn && piece.color == .black {
				app.draw_piece_at_coordinate(app.black_pawn, x_coord, y_coord)
			}
			else if piece.shape == .rook && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_rook, x_coord, y_coord)
			}
			else if piece.shape == .knight && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_knight, x_coord, y_coord)
			}
			else if piece.shape == .bishop && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_bishop, x_coord, y_coord)
			}
			else if piece.shape == .queen && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_queen, x_coord, y_coord)
			}
			else if piece.shape == .king && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_king, x_coord, y_coord)
			}
			else if piece.shape == .pawn && piece.color == .white {
				app.draw_piece_at_coordinate(app.white_pawn, x_coord, y_coord)
			}
		}
	}
}

fn (app App) draw_piece_at_coordinate(piece gg.Image, x int, y int) {
	square_width := f32(app.game_board_image.width) / f32(game_board_dimension)
	square_height := f32(app.game_board_image.height) / f32(game_board_dimension)

	x_coord := square_width * f32(x) + (square_width - f32(piece.width)) / 2.0
	y_coord := square_height * f32(y) + (square_height - f32(piece.height)) / 2.0

	app.gg.draw_image(x_coord, y_coord, f32(piece.width), f32(piece.height), piece)
}

fn place_piece_new_game(mut game_board [][]Piece, piece Piece, y_coord int, x_coord int) {
	if game_board[y_coord][x_coord].shape == .empty_square  {
		mut local_piece := piece
		local_piece.coords.x_coord = x_coord
		local_piece.coords.y_coord = y_coord
		game_board[y_coord][x_coord] = local_piece
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

fn move_piece(mut game_board [][]Piece, origin_coords Coords, destination_coords Coords) {
	mut piece := game_board[origin_coords.y_coord][origin_coords.x_coord]
	piece.coords.y_coord = destination_coords.y_coord
	piece.coords.x_coord = destination_coords.x_coord
	game_board[destination_coords.y_coord][destination_coords.x_coord] = piece
	game_board[origin_coords.y_coord][origin_coords.x_coord] = Piece{shape: .empty_square, coords: origin_coords}
}

fn coords_in_legal_moves(legal_moves []Coords, coords Coords) bool {
	mut ret := false
	dump(legal_moves)
	for legal_move in legal_moves {
		if (legal_move.y_coord == coords.y_coord) && (legal_move.x_coord == coords.x_coord) {
			ret = true
		}
	}
	return ret
}

fn (mut app App) handle_coords(coords Coords) {
	if (app.selection_state == .origin_coords) && (app.game_board[coords.y_coord][coords.x_coord].color == app.current_player) {
		app.origin_coords = coords
		app.selection_state = .destination_coords
		set_legal_moves_wrapper(mut app.game_board)
	} else if app.selection_state == .destination_coords && coords_in_legal_moves(app.game_board[app.origin_coords.y_coord][app.origin_coords.x_coord].legal_moves, coords) {
		app.destination_coords = coords
		move_piece(mut app.game_board, app.origin_coords, app.destination_coords)
		app.current_player = opposite_color(app.current_player)
		app.selection_state = .origin_coords
	}
}

fn click(x f32, y f32, button gg.MouseButton, mut app App) {
	game_board_width := app.game_board_image.width
	game_board_height := app.game_board_image.height

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
			// .r { app.new_game() }
			.q { app.gg.quit() }
			else {}
		}
	}
}

const game_board_dimension = 8
const empty_game_board = [][]Piece{len: game_board_dimension, cap: game_board_dimension, init: []Piece{len: game_board_dimension, cap: game_board_dimension, init: Piece{}}}

enum SelectionState {
	not_set = -1
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
	relative_coords     Coords
	conditions []fn(piece Piece)bool
	modifiers []string
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
	return Coords{y_coord: (a.y_coord + b.y_coord), x_coord: (a.x_coord + b.x_coord)}
}

enum Shape {
	not_set = -2
	empty_square = -1
	rook         = 0
	knight       = 1
	bishop       = 2
	queen        = 3
	king         = 4
	pawn         = 5
}

struct Piece {
	shape Shape
	color Color
mut:
	coords Coords
	legal_moves  []Coords
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
		place_piece_new_game(mut game_board, piece, y_coord, x_coord)
	}
	y_coord = 7
	white_pieces := get_starting_pieces(Color.white)
	for x_coord, piece in white_pieces {
		place_piece_new_game(mut game_board, piece, y_coord, x_coord)
	}
	// setup the pawn pieces
	y_coord = 1
	black_pawn := Piece { shape: .pawn color: .black}
	for x_coord in 0 .. game_board_dimension {
		place_piece_new_game(mut game_board, black_pawn, y_coord, x_coord)
	}
	y_coord = 6
	white_pawn := Piece { shape: .pawn color: .white}
	for x_coord in 0 .. game_board_dimension {
		place_piece_new_game(mut game_board, white_pawn, y_coord, x_coord)
	}
}

fn set_empty_pieces(mut game_board [][]Piece) {
	for y_coord in 0 .. game_board_dimension {
		for x_coord in 0 .. game_board_dimension {
			game_board[y_coord][x_coord] = Piece {
				shape: .empty_square
				coords: Coords{y_coord: y_coord, x_coord: x_coord}
			}
		}
	}
}


struct App {
mut:
	gg               &gg.Context = unsafe { nil }
	black_bishop     gg.Image
	black_king       gg.Image
	black_knight     gg.Image
	black_pawn       gg.Image
	black_queen      gg.Image
	black_rook       gg.Image
	white_bishop     gg.Image
	white_king       gg.Image
	white_knight     gg.Image
	white_pawn       gg.Image
	white_queen      gg.Image
	white_rook       gg.Image
	game_board_image gg.Image
	game_board       [][]Piece
	selection_state  SelectionState
	current_player   Color
	origin_coords Coords
	destination_coords Coords
}

fn origin_sixth_row(piece Piece) bool {
	return piece.coords.y_coord == 6
}

fn get_absolute_coords(piece_coords Coords, relative_coords Coords) Coords {
	return piece_coords + relative_coords
}

fn within_board(absolute_coords Coords) bool {
	return absolute_coords.x_coord >= 0 && absolute_coords.x_coord < game_board_dimension && absolute_coords.y_coord >= 0 && absolute_coords.y_coord < game_board_dimension
}

fn all_conditions_met(piece Piece, conditions []fn(piece Piece) bool) bool {
	for condition in conditions {
		if condition(piece) == false {
			return false
		}
	}
	return true
}

fn set_legal_moves(mut piece Piece) {
	// mut local_piece := piece
	relative_coords_database :=
		{
			'white_pawn':
			[
				RelativeCoords{relative_coords: Coords{y_coord: -2, x_coord: 0}, conditions: [origin_sixth_row], modifiers: ['no-repeat']},
				RelativeCoords{relative_coords: Coords{y_coord: -1, x_coord: 0}, conditions: [], modifiers: ['no-repeat']},
				// RelativeCoords{relative_coords: Coords{y_coord: -1, x_coord: -1}, conditions: [destination_capture], modifiers: ['no-repeat']},
				// RelativeCoords{relative_coords: Coords{y_coord: -1, x_coord: 1}, conditions: [destination_capture], modifiers: ['no-repeat']},
			]
		}
	if piece.shape == .pawn && piece.color == .white {
		for relative_coords in relative_coords_database['white_pawn'] {
			absolute_coords := piece.coords + relative_coords.relative_coords
			if all_conditions_met(piece, relative_coords.conditions) && within_board(absolute_coords) {
				piece.legal_moves << absolute_coords
			}
		}
	}
}

fn set_legal_moves_wrapper(mut game_board [][]Piece) {
	for y_coord, mut row in game_board {
		for x_coord, mut piece in row {
			if piece.shape != .empty_square {
				set_legal_moves(mut piece)
			}
		}
	}
}

fn (mut app App) new_game() {
	app.selection_state = .origin_coords
	app.current_player = .white
	app.game_board = [][]Piece{len: 8, cap: 8, init: []Piece{len: 8, cap: 8, init: Piece{}}}
	set_empty_pieces(mut app.game_board)
	set_pieces_new_game(mut app.game_board)
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
