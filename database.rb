def getdb()
    return SQLite3::Database.new("db/db.db")
end
def login(params)
    db = getdb()
    db.results_as_hash = true
    password = db.execute('SELECT password, id FROM user WHERE username=?', params["username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["password"]) == true
            session[:username] = params["username"]
            session[:id] = password[0]["id"]
            return true
        else
            return false
        end
    else
        return false
    end
end

def home(params)
    db = getdb()
    db.results_as_hash = true
    posts = db.execute("SELECT comments.id, comments.comment_author, comments.comment_text, comments.dislikecount, user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id INNER JOIN comments on user.id = comments.comment_author")
    slim(:home, locals:{posts: posts})
end

def profile(params)
    db = getdb()
    db.results_as_hash = true
    # posts = db.execute("SELECT comments.id, comments.comment_author, comments.comment_text, comments.dislikecount, user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id INNER JOIN comments on user.id = comments.comment_author WHERE author_id= ?", 5)
    posts = db.execute("SELECT * from posts INNER JOIN user on user.id = posts.author_id INNER JOIN comments on user.id = comments.comment_author WHERE author_id =?", session[:id])
    p session[:id]
    p posts
    slim(:profile, locals:{posts: posts})
end

def signup(params)
    db = getdb()
    db.results_as_hash = true
    if params["username"] != "" && params["password"]
        db.execute('INSERT INTO user(username, password) VALUES (?, ?)', params["username"], BCrypt::Password.create(params["password"]))
        return true
    else
        return false
    end
end

def postpost(params)
    db = getdb()
    db.execute("INSERT INTO posts(post_title, post_text, author_id ) VALUES (?,?,?)",params["post_title"],params["post_text"],session[:id])
end

def deletepost(params)
    db = getdb()
    db.execute("DELETE FROM posts WHERE post_id = (?)", params["id"])
end

def insertcomment(params)
    db = getdb()
    db.execute("INSERT INTO comments(comment_author, comment_text, dislikecount ) VALUES (?,?,?)", session[:id], params["comment_text"], 0 )
end