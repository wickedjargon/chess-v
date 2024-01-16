import gg
import os

struct App {
mut:
	gg                 &gg.Context = unsafe { nil }
	black_bishop        gg.Image
	black_king          gg.Image
	black_knight        gg.Image
	black_pawn          gg.Image
	black_queen         gg.Image
	black_rook          gg.Image
	white_bishop        gg.Image
	white_king          gg.Image
	white_knight        gg.Image
	white_pawn          gg.Image
	white_queen         gg.Image
	white_rook          gg.Image
	board               gg.Image
}

fn (mut app App) init_images_wrapper() {
	app.init_images() or { panic(err) }
}

fn (app App) draw_board() {
	app.gg.draw_image(0.0, 0.0, f32(app.board.width), f32(app.board.height), app.board)
}

// fn (app App) draw_pieces() {
// 	mut x := app.board.width / f32(8.0) / f32(2.0) - (app.black_bishop.width / f32(2.0))
// 	y := app.board.height / f32(8.0) / f32(2.0) - (app.black_bishop.height / f32(2.0))
// 	app.gg.draw_image(x, y, f32(app.black_rook.width), f32(app.black_rook.height), app.black_rook)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_knight.width), f32(app.black_knight.height), app.black_knight)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_bishop.width), f32(app.black_bishop.height), app.black_bishop)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_queen.width), f32(app.black_queen.height), app.black_queen)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_king.width), f32(app.black_king.height), app.black_king)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_bishop.width), f32(app.black_bishop.height), app.black_bishop)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_knight.width), f32(app.black_knight.height), app.black_king)

// 	x += f32(f32(app.board.width) / 8.0)
// 	app.gg.draw_image(x, y, f32(app.black_rook.width), f32(app.black_rook.height), app.black_rook)

// }

fn (app App) place_piece_at_coordinate(piece gg.Image, x int, y int) {
    square_width := f32(app.board.width) / 8.0
    square_height := f32(app.board.height) / 8.0

    x_coord := square_width*f32(x) + (square_width - f32(piece.width)) / 2.0
    y_coord := square_height*f32(y) + (square_height - f32(piece.height)) / 2.0

    app.gg.draw_image(x_coord, y_coord, f32(piece.width), f32(piece.height), piece)
}


fn (app App) draw_pieces() {
	app.place_piece_at_coordinate(app.black_rook, 0, 0)
	app.place_piece_at_coordinate(app.black_knight, 1, 0)
	app.place_piece_at_coordinate(app.black_bishop, 2, 0)
	app.place_piece_at_coordinate(app.black_queen, 3, 0)
	app.place_piece_at_coordinate(app.black_king, 4, 0)
	app.place_piece_at_coordinate(app.black_bishop, 5, 0)
	app.place_piece_at_coordinate(app.black_knight, 6, 0)
	app.place_piece_at_coordinate(app.black_rook, 7, 0)
	app.place_piece_at_coordinate(app.black_rook, 7, 0)

	app.place_piece_at_coordinate(app.white_rook, 0, 7)
	app.place_piece_at_coordinate(app.white_knight, 1, 7)
	app.place_piece_at_coordinate(app.white_bishop, 2, 7)
	app.place_piece_at_coordinate(app.white_queen, 3, 7)
	app.place_piece_at_coordinate(app.white_king, 4, 7)
	app.place_piece_at_coordinate(app.white_bishop, 5, 7)
	app.place_piece_at_coordinate(app.white_knight, 6, 7)
	app.place_piece_at_coordinate(app.white_rook, 7, 7)

	for x in 0..8 {
		app.place_piece_at_coordinate(app.white_pawn, x, 6)
	}

	for x in 0..8 {
		app.place_piece_at_coordinate(app.black_pawn, x, 1)
	}
}



fn frame(app &App) {
	app.gg.begin()
	app.draw_board()
	app.draw_pieces()
	app.gg.end()
}

fn (mut app App) init_images() ! {
	app.black_bishop = app.gg.create_image(os.resource_abs_path('./assets/black_bishop.png'))!
	app.black_king = app.gg.create_image(os.resource_abs_path('./assets/black_king.png'))!
	app.black_knight = app.gg.create_image(os.resource_abs_path('./assets/black_knight.png'))!
	app.black_pawn = app.gg.create_image(os.resource_abs_path('./assets/black_pawn.png'))!
	app.black_queen = app.gg.create_image(os.resource_abs_path('./assets/black_queen.png'))!
	app.black_rook = app.gg.create_image(os.resource_abs_path('./assets/black_rook.png'))!
	app.white_bishop = app.gg.create_image(os.resource_abs_path('./assets/white_bishop.png'))!
	app.white_king = app.gg.create_image(os.resource_abs_path('./assets/white_king.png'))!
	app.white_knight = app.gg.create_image(os.resource_abs_path('./assets/white_knight.png'))!
	app.white_pawn = app.gg.create_image(os.resource_abs_path('./assets/white_pawn.png'))!
	app.white_queen = app.gg.create_image(os.resource_abs_path('./assets/white_queen.png'))!
	app.white_rook = app.gg.create_image(os.resource_abs_path('./assets/white_rook.png'))!
	app.board = app.gg.create_image(os.resource_abs_path('./assets/board.png'))!
}

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		user_data: app
		// window_title: 'Chess'
		// frame_fn: frame
		// event_fn: on_event
		init_fn: app.init_images_wrapper
		width: 1000
		height: 700
		frame_fn: frame

	)
	app.gg.run()
}
