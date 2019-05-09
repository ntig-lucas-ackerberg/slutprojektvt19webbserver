module Mymodel
    
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

    # def home(params)
    #     db = getdb()
    #     db.results_as_hash = true
    #     posts = db.execute("SELECT user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id")
    #     comments = db.execute("SELECT * FROM comments")
    #     # session[:postcomment] = posts[0]["post_id"]
    #     slim(:home, locals:{posts: posts, comments: comments})
    # end

    def profile(params)
        db = getdb()
        db.results_as_hash = true
        # query = <<-SQL
        # SELECT * from posts 
        #     INNER JOIN user on user.id = posts.author_id  
        #     WHERE author_id =?
        # SQL
        # posts = db.execute(query, params["id"] )
        posts = db.execute("SELECT user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id WHERE posts.author_id=?", params["id"])
        p params["id"]
        p session[:id]
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
        db.execute("DELETE FROM posts WHERE post_id = (?)", params["post_id"])
    end

    def insertcomment(params)
        db = getdb()
        db.execute("INSERT INTO comments(comment_author, comment_text, dislikecount, post_id ) VALUES (?,?,?,?)", session[:id], params["comment_text"], 0, params["post_id"])
    end

    def updatepost(params)
        db = getdb()
        db.execute("UPDATE posts SET post_title = ?,post_text = ? WHERE post_id = ?",params["post_title"],params["post_text"],params["post_id"] )
    end

    def editpost(params)
        db = getdb()
        db.results_as_hash = true
        result = db.execute("SELECT post_id, post_title, post_text, author_id FROM posts WHERE post_id = ?", params["post_id"])
        slim(:editpost, locals:{result: result})
    end

    def likepost(params)
        db = getdb()
        result = db.execute("UPDATE posts SET dislikecounter = dislikecounter + 1) WHERE post_id = ?", params["post_id"], params["post_id"] )
    end

    def dislikepost(params)
        db = getdb()
        result = db.execute("UPDATE posts SET dislikecounter = ((SELECT dislikecounter FROM posts WHERE post_id=?) - 1) WHERE post_id = ?", params["post_id"], params["post_id"] )
    end

    def likecomment(params)
        db = getdb()
        result = db.execute("UPDATE comments SET dislikecount = ((SELECT dislikecount FROM comments WHERE comment_id=?) + 1) WHERE comment_id = ?", params["comment_id"], params["comment_id"] )
    end

    def dislikecomment(params)
        db = getdb()
        result = db.execute("UPDATE comments SET dislikecount = ((SELECT dislikecount FROM comments WHERE comment_id=?) - 1) WHERE comment_id = ?", params["comment_id"], params["comment_id"] )
    end

    def get_posts_with_comments()
        db = getdb()
        db.results_as_hash = true
        comments = db.execute("SELECT * FROM comments")
        posts = db.execute("SELECT user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id")
        posts.each do |post|
            post["comments"] = comments.select do |comment|
                comment["post_id"] == post["post_id"]
                end
            end
        return posts
    end
end