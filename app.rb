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
    postpost(params)
    redirect("/profile/#{session[:id]}")
end

post('/:id/delete') do
    deletepost(params)
    redirect("/profile/#{session[:id]}")
end

post('/') do 
    insertcomment(params)
    redirect('/')
end

post('/edit/:id/update') do 
    updatepost(params)
    redirect("/profile/#{session[:id]}")
end

get('/edit/:id') do 
    editpost(params)
end