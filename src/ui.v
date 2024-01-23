module main

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

fn frame(app &App) {
	app.gg.begin()
	app.draw_game_board()
	app.draw_pieces()
	if app.selection_state == .destination_coords {
		app.draw_legal_moves()
	}
	app.gg.end()
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
