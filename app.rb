require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require 'byebug'
enable :sessions
require_relative 'database.rb' 

get('/') do
    home(params)
end

post('/logout') do
    session[:username] = nil
    session[:password] = nil
    session.destroy
    redirect('/')
end

get('/newpost') do
    slim(:newpost)
end

post('/login') do
    if login(params) == true
        redirect('/')
    else
        session[:wrong] = true
        redirect('/')
    end
end

get('/profile/:id') do
    profile(params)
end

get('/signup') do
    slim(:signup)
end

post('/signup') do
    if signup(params) == true
        redirect('/')
    else
        session[:fillout] = true
        redirect('/signup')
    end
end

post('/newpost') do
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO posts(post_title, post_text, author_id ) VALUES (?,?,?)",params['post_title'],params['post_text'],session[:id].to_i )
    redirect("/profile/#{session[:id]}")
end
