module main

import vweb
import db.sqlite
import rand

struct App {
	vweb.Context
mut:
	db sqlite.DB
}

struct Question {
	id       int    @[primary; sql: serial]
	game_id  int
	question string
	answer   string
}

struct Column_Title {
	id        int    @[primary; sql: serial]
	game_id   int
	col_title string
}

struct Game {
	id         int            @[primary; sql: serial]
	title      string
	uuid       string         @[unique]
	col_titles []Column_Title @[fkey: 'game_id']
	nr_rows    int
	questions  []Question     @[fkey: 'game_id']
}

fn main() {
	mut app := App{}
	app.db = sqlite.connect(':memory:')!

	sql app.db {
		create table Question
		create table Game
		create table Column_Title
	}!

	game := Game{
		title: 'First game'
		uuid: 'testing'
		col_titles: [Column_Title{
			col_title: 'Column 1'
		}, Column_Title{
			col_title: 'Column 2'
		}, Column_Title{
			col_title: 'Column 3'
		}, Column_Title{
			col_title: 'Column 4'
		}, Column_Title{
			col_title: 'Column 5'
		}]
		nr_rows: 5
		questions: [
			Question{
				question: 'This is the current year.'
				answer: 'What is 2023'
			},
			Question{
				question: 'What is the capital of France?'
				answer: 'What is Paris'
			},
			Question{
				question: 'Who painted the Mona Lisa?'
				answer: 'Who is Leonardo da Vinci'
			},
			Question{
				question: 'What is the square root of 64?'
				answer: 'What is 8'
			},
			Question{
				question: 'Who wrote the play "Romeo and Juliet"?'
				answer: 'Who is William Shakespeare'
			},
			Question{
				question: 'What is the largest planet in our solar system?'
				answer: 'What is Jupiter'
			},
			Question{
				question: 'Who invented the telephone?'
				answer: 'Who is Alexander Graham Bell'
			},
			Question{
				question: 'What is the chemical symbol for gold?'
				answer: 'What is Au'
			},
			Question{
				question: 'What is the tallest mountain in the world?'
				answer: 'What is Mount Everest'
			},
			Question{
				question: 'Who wrote the novel "Pride and Prejudice"?'
				answer: 'Who is Jane Austen'
			},
			Question{
				question: 'What is the capital of Australia?'
				answer: 'What is Canberra?'
			},
			Question{
				question: 'Who is the current President of the United States?'
				answer: 'Who is Joe Biden?'
			},
			Question{
				question: 'What is the largest ocean on Earth?'
				answer: 'What is the Pacific Ocean?'
			},
			Question{
				question: 'Who painted the famous artwork "Starry Night"?'
				answer: 'Who is Vincent van Gogh?'
			},
			Question{
				question: 'What is the chemical symbol for water?'
				answer: 'What is H2O?'
			},
			Question{
				question: 'What is the capital of Canada?'
				answer: 'What is Ottawa?'
			},
			Question{
				question: 'Who is the author of "To Kill a Mockingbird"?'
				answer: 'Who is Harper Lee?'
			},
			Question{
				question: 'What is the largest desert in the world?'
				answer: 'What is the Sahara Desert?'
			},
			Question{
				question: 'Who discovered the theory of relativity?'
				answer: 'Who is Albert Einstein?'
			},
			Question{
				question: 'What is the chemical formula for table salt?'
				answer: 'What is NaCl?'
			},
			Question{
				question: 'Who wrote the famous play "Hamlet"?'
				answer: 'Who is William Shakespeare?'
			},
			Question{
				question: 'What is the tallest waterfall in the world?'
				answer: 'What is Angel Falls?'
			},
			Question{
				question: 'Who is the Greek god of thunder?'
				answer: 'Who is Zeus?'
			},
			Question{
				question: 'What is the largest animal on Earth?'
				answer: 'What is the blue whale?'
			},
			Question{
				question: 'Who painted the famous artwork "The Last Supper"?'
				answer: 'Who is Leonardo da Vinci?'
			},
		]
	}

	sql app.db {
		insert game into Game
	}!

	app.serve_static('/output.css', 'output.css')
	app.serve_static('/htmx.min.js', 'htmx.min.js')
	vweb.run(app, 8080)
}

@['/game/:id']
pub fn (mut app App) game(uuid string) !vweb.Result {
	games := sql app.db {
		select from Game where uuid == uuid limit 1
	}!
	game := games[0] or { return app.redirect('/edit/${uuid}') }
	return $vweb.html()
}

@['/question/:id']
pub fn (mut app App) question(id int) !vweb.Result {
	questions := sql app.db {
		select from Question where id == id limit 1
	}!
	question := questions[0] or { return app.not_found() }
	return $vweb.html()
}

@['/close'; post]
pub fn (mut app App) close() !vweb.Result {
	return $vweb.html()
}

@['/edit/:uuid']
pub fn (mut app App) edit(uuid string) !vweb.Result {
	games := sql app.db {
		select from Game where uuid == uuid
	}!
	mut game := Game{}
	if games.len == 0 {
		new_game := Game{
			uuid: uuid
			col_titles: []Column_Title{len: 5}
			nr_rows: 5
			questions: []Question{len: 25}
		}
		sql app.db {
			insert new_game into Game
		}!
		new_games := sql app.db {
			select from Game where uuid == uuid limit 1
		}!
		game = new_games[0]
	} else {
		game = games[0]
	}
	return $vweb.html()
}

@['/update_title/:id'; post]
pub fn (mut app App) update_title(id int) !vweb.Result {
	title := app.form['title${id}'] or { return app.text('') }
	sql app.db {
		update Column_Title set col_title = title where id == id
	}!
	return app.text(title)
}

@['/edit_question/:id'; get]
pub fn (mut app App) editquestion(id int) !vweb.Result {
	return $vweb.html()
}

@['/update_question/:id'; post]
pub fn (mut app App) updatequestion(id int) !vweb.Result {
	question := app.form['question'] or { return app.text('') }
	answer := app.form['answer'] or { return app.text('') }
	sql app.db {
		update Question set question = question, answer = answer where id == id
	}!
	return $vweb.html()
}

@['/update_game_title/:id'; post]
pub fn (mut app App) update_game_title(id int) !vweb.Result {
	title := app.form['title'] or { return app.text('') }
	sql app.db {
		update Game set title = title where id == id
	}!
	return app.text(title)
}
