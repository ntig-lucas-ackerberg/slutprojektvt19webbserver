require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require 'securerandom'
require 'byebug'
enable :sessions
require_relative 'database.rb' 

include Mymodel

# Display Starting Page
#
get('/') do
    posts = get_posts_with_comments()
    slim(:home, locals:{posts: posts})
end

# Logs the current user out of the page and updates sessions
#
post('/logout') do
    session[:username] = nil
    session[:password] = nil
    session.destroy
    redirect('/')
end

# Loads the page where you create a new post on the website
#
get('/newpost') do
    slim(:newpost)
end

# Attempts to login on the website and if it succeeds, update sessions
#
# @param [string] username
# @param [string] password
#
# @see Model#login
post('/login') do
    if login(params) == true
        redirect('/')
    else
        session[:wrong] = true
        redirect('/')
    end
end

# Show the posts that you've created on your profile.
#
# @param [Interger] id, The id of your profile/user
#
# @see Model#deletepost
get('/profile/:id') do
    profile(params)
end

# Loads the route where you can signup as a new user.
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#signup
get('/signup') do
    slim(:signup)
end

# Attempts registration of a user and updates the session if certain requirements isn't met.
#
# @param [String] username, The username
# @param [String] password, The password
#
# @see Model#signup
post('/signup') do
    if signup(params) == true
        redirect('/')
    else
        session[:fillout] = true
        redirect('/signup')
    end
end

# Creates a new post and redirects to '/profile#{session[:id]} where you can see your profiles posts
#
# @param [String] post_title, The title of the post
# @param [String] post_text, The content of the post
#
# @see Model#postpost
post('/newpost') do
    postpost(params)
    redirect("/profile/#{session[:id]}")
end

# Deletes a post and redirects to '/profile#{session[:id]} where you can see your profiles posts
#
# @param [Interger] post_id, The id of the post that you want to to delete
#
# @see Model#deletepost
post('/:post_id/delete') do
    deletepost(params)
    redirect("/profile/#{session[:id]}")
end

# Creates a comment and redirects to the starting page where you can see every post including the different comments attached to it.
#
# @param [Interger] post_id, The id of the post that you attach your comment to
# @param [Interger] comment_id, The id of the comment that you are posting
#
# @see Model#insertcomment
post('/submitcomment/:post_id') do 
    insertcomment(params)
    redirect('/')
end

# Post the edits you've written into the page and on the current poat that you've selected
#
# @param [Interger] post_id, The id of the post the you want to update
# @param [String] post_title, The title of the post
# @param [String] post_text, The text of the post
#
# @see Model#updatepost
post('/edit/:post_id/update') do 
    updatepost(params)
    redirect("/profile/#{session[:id]}")
end

# Loads the route where you can edit thingd in your selected post
#
# @param [Interger] post_id, The id of the post the you want to update
#
# @see Model#editpost
get('/edit/:post_id') do 
    editpost(params)
end

# Update the likecounter of the selected post
#
# @param [Interger] post_id, The id of the post the you want to update
#
# @see Model#likepost
post('/likepost/:post_id') do
    likepost(params)
    redirect('/')
end

# Update the likecounter of the selected post
#
# @param [Interger] post_id, The id of the post the you want to update
#
# @see Model#dislikepost
post('/dislikepost/:post_id') do
    dislikepost(params)
    redirect('/')
end

# Likes the selected comment
#
# @param [Interger] comment_id, The id of the comment the you want to update
#
# @see Model#dislikecomment
post('/likecomment/:comment_id') do
    likecomment(params)
    redirect('/')
end

# Dislikes the selected comment
#
# @param [Interger] comment_id, The id of the comment the you want to update
#
# @see Model#dislikecomment
post('/dislikecomment/:comment_id') do
    dislikecomment(params)
    redirect('/')
end


