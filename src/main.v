import gg
import os


const game_game_board_length = 8

///////////
// Piece //
///////////

// `Piece` here is an umbrella term for not only all black and white
// pieces, but also empty_squres. illegal_move/legal_move is used in
// the legal_moves_game_board 2D array
enum Piece {
	illegal_move = -3
	legal_move = -2
	empty_square = -1

	black_rook = 0
	black_knight
	black_bishop
	black_queen
	black_king
	black_pawn

	white_rook = 10
	white_knight
	white_bishop
	white_queen
	white_king
	white_pawn
}

enum Player {
	white
	black
}

///////////
// game_board //
///////////

fn (mut app App) clear_game_board() {
	for y in 0 .. game_game_board_length {
		for x in 0 .. game_game_board_length {
			app.game_board[y][x] = .empty_square
		}
	}
}

fn (mut app App) clear_legal_moves_game_board() {
	for y in 0 .. game_game_board_length {
		for x in 0 .. game_game_board_length {
			app.legal_moves_game_board[y][x] = .illegal_move
		}
	}
}

fn (mut app App) move_piece() {
	app.game_board[app.destination_coords[0]][app.destination_coords[1]] = app.origin_piece
	app.game_board[app.origin_coords[0]][app.origin_coords[1]] = .empty_square
}

fn (app App) piece_matches_player() bool {
	if app.current_player == .black && int(app.origin_piece) in []int{len: 6, init: index} {
		return true
	}
	if app.current_player == .white && int(app.origin_piece) in []int{len: 6, init: index + 10} {
		return true
	}
	return false
}

// fn (app App) update_legal_moves_game_board() {
// 	app.origin_coords[0]
// 	app.origin_coords[1]

// 	mut y := 0
// 	mut x := 0
// 	for {
// 		if y >= game_board_width {
// 		}
// 	}
// }


fn (mut app App) handle_origin_coords(y_coord int, x_coord int) {
	app.origin_coords = [y_coord, x_coord]
	app.origin_piece = app.game_board[y_coord][x_coord]
	if app.piece_matches_player() {
		// app.update_legal_moves_game_board()
	} else { return }
	app.selection_state = .destination_coords
}

fn (mut app App) handle_coords(y_coord int, x_coord int) {
	if app.selection_state == .origin_coords {
		app.handle_origin_coords(y_coord, x_coord)
	} else if app.selection_state == .destination_coords {
		app.destination_coords = [y_coord, x_coord]
		app.selection_state = .origin_coords
		app.move_piece()
	}
}

// fn (mut app App) set_piece_offsets() {
// 	mut offsets := {
// 		Piece.white_pawn:
// 		{
			
// 		}
// 	}
// }

fn (mut app App) new_game() {
	app.selection_state = .origin_coords
	app.current_player = .white
	app.clear_game_board()
	app.clear_legal_moves_game_board()

	// app.set_piece_offsets()

	black_pieces := [Piece.black_rook, Piece.black_knight, Piece.black_bishop, Piece.black_queen,
		Piece.black_king, Piece.black_bishop, Piece.black_knight, Piece.black_rook]
	for x_coord, piece in black_pieces {
		app.game_board[0][x_coord] = piece
	}

	white_pieces := [Piece.white_rook, Piece.white_knight, Piece.white_bishop, Piece.white_queen,
		Piece.white_king, Piece.white_bishop, Piece.white_knight, Piece.white_rook]
	for x_coord, piece in white_pieces {
		app.game_board[7][x_coord] = piece
	}

	for x_coord in 0 .. game_game_board_length {
		app.game_board[1][x_coord] = Piece.black_pawn
	}

	for x_coord in 0 .. game_game_board_length {
		app.game_board[6][x_coord] = Piece.white_pawn
	}
}

//////////
// draw //
//////////

fn (mut app App) init_images_wrapper() {
	app.init_images() or { panic(err) }
}

fn (app App) draw_game_board() {
	app.gg.draw_image(0.0, 0.0, f32(app.game_board_image.width), f32(app.game_board_image.height),
		app.game_board_image)
}

fn (app App) draw_piece_at_coordinate(piece gg.Image, x int, y int) {
	square_width := f32(app.game_board_image.width) / f32(game_game_board_length)
	square_height := f32(app.game_board_image.height) / f32(game_game_board_length)

	x_coord := square_width * f32(x) + (square_width - f32(piece.width)) / 2.0
	y_coord := square_height * f32(y) + (square_height - f32(piece.height)) / 2.0

	app.gg.draw_image(x_coord, y_coord, f32(piece.width), f32(piece.height), piece)
}

fn (app App) draw_pieces() {
	for y_coord, rows in app.game_board {
		for x_coord, square in rows {
			if square == Piece.black_rook {
				app.draw_piece_at_coordinate(app.black_rook, x_coord, y_coord)
			} else if square == Piece.black_knight {
				app.draw_piece_at_coordinate(app.black_knight, x_coord, y_coord)
			} else if square == Piece.black_bishop {
				app.draw_piece_at_coordinate(app.black_bishop, x_coord, y_coord)
			} else if square == Piece.black_queen {
				app.draw_piece_at_coordinate(app.black_queen, x_coord, y_coord)
			} else if square == Piece.black_king {
				app.draw_piece_at_coordinate(app.black_king, x_coord, y_coord)
			} else if square == Piece.black_pawn {
				app.draw_piece_at_coordinate(app.black_pawn, x_coord, y_coord)
			} else if square == Piece.white_rook {
				app.draw_piece_at_coordinate(app.white_rook, x_coord, y_coord)
			} else if square == Piece.white_knight {
				app.draw_piece_at_coordinate(app.white_knight, x_coord, y_coord)
			} else if square == Piece.white_bishop {
				app.draw_piece_at_coordinate(app.white_bishop, x_coord, y_coord)
			} else if square == Piece.white_queen {
				app.draw_piece_at_coordinate(app.white_queen, x_coord, y_coord)
			} else if square == Piece.white_king {
				app.draw_piece_at_coordinate(app.white_king, x_coord, y_coord)
			} else if square == Piece.white_pawn {
				app.draw_piece_at_coordinate(app.white_pawn, x_coord, y_coord)
			}
		}
	}
}

fn frame(app &App) {
	app.gg.begin()
	app.draw_game_board()
	app.draw_pieces()
	app.gg.end()
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

///////////
// event //
///////////

enum SelectionState {
	origin_coords
	destination_coords
}

fn click(x f32, y f32, button gg.MouseButton, mut app App) {
	game_board_width := app.game_board_image.width
	game_board_height := app.game_board_image.height

	// Check if the click is within the chessgame_board bounds
	if x < 0.0 || x > f32(game_board_width) || y < 0.0 || y > f32(game_board_height) {
		return
	}

	// Calculate the square indices based on the clicked coordinates
	square_size_y := f32(game_board_height) / f32(game_game_board_length)
	square_size_x := f32(game_board_width) / f32(game_game_board_length)

	y_coord := int(y / square_size_y)
	x_coord := int(x / square_size_x)

	app.handle_coords(y_coord, x_coord)

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

/////////
// app //
/////////

struct App {
mut:
	gg                 &gg.Context = unsafe { nil }
	black_bishop       gg.Image
	black_king         gg.Image
	black_knight       gg.Image
	black_pawn         gg.Image
	black_queen        gg.Image
	black_rook         gg.Image
	white_bishop       gg.Image
	white_king         gg.Image
	white_knight       gg.Image
	white_pawn         gg.Image
	white_queen        gg.Image
	white_rook         gg.Image
	game_board_image         gg.Image
	game_board              [game_game_board_length][game_game_board_length]Piece
	selection_state    SelectionState
	origin_coords      []int
	destination_coords []int
	origin_piece Piece
	current_player Player
	legal_moves_game_board [game_game_board_length][game_game_board_length]Piece
}

fn main() {
	mut app := &App{}
	app.new_game()
	app.gg = gg.new_context(
		user_data: app
		window_title: 'Chess'
		// frame_fn: frame
		// event_fn: on_event
		init_fn: app.init_images_wrapper
		width: 1000
		height: 700
		click_fn: click
		frame_fn: frame
		event_fn: on_event
	)
	app.gg.run()
}
