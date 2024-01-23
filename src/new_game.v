module main

fn place_piece_new_game(mut game_board [][]Piece, piece Piece, destination_coords Coords) {
	destination_piece := game_board[destination_coords.y_coord][destination_coords.x_coord]
	if destination_piece.shape == .empty_square {
		mut local_piece := piece
		local_piece.coords = destination_coords
		game_board[destination_coords.y_coord][destination_coords.x_coord] = local_piece
	}
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
}
