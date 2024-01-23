// NOTE: command used to increase image sizes: `mogrify -filter point -resize 400% *.png` (an imagemagick command)
//

module main

import gg
import os

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
