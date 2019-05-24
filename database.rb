module Mymodel

    #Connects to database
    def getdb()
        db = SQLite3::Database.new("db/db.db")
    end

    # Attempts to login the user
    #
    # @params [Hash] params form data
    # @option params [String] username The username
    # @option params [String] password The password
    #
    # @return [Integer] The ID of the user
    # @return [False] If the password does not match woth the encrypted password.
    # @return [False] If the password array is empty.
    def login(params)
        db = getdb()
        db.results_as_hash = true
        password = db.execute('SELECT password, id FROM user WHERE username=?', params["username"])
        if password != []
            if (BCrypt::Password.new(password[0][0]) == params["password"]) == true
                return password[0]["id"]
            else
                return false
            end
        else
            return false
        end
    end

    # Shows all the posts that the current user has
    #
    # @params [Hash] params form data
    # @option params [Interger] id the id of the current user
    #
    # @return [Array] Array of the posts connected with the current user.
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
    end

    # Attempts to signup a new user
    #
    # @params [Hash] params form data
    # @option params [String] username, the username that the user wants to have
    # @option params [String] password, the password that the user wants to have
    #
    # @return [true] If the array of the posts connected with the current user.
    # @return [False] If the password does not match woth the encrypted password.
    # @return [False] If the password array is empty.
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

    # Attempts to validate the information in the input.
    #
    # @param Input [String] Whatever the input may be that is to be validated.
    #
    # @return [true] if the information is correct
    # @return [false] if the information is incorrect
    def validateifempty(params)
        params.values.each do |element|
            if element == ""
                return true
            end
        end
        return false
    end

    def postpost(params, user_id)
        db = getdb()
        db.execute("INSERT INTO posts(post_title, post_text, author_id ) VALUES (?,?,?)",params["post_title"],params["post_text"],user_id)
    end

    def deletepost(params)
        db = getdb()
        db.execute("DELETE FROM posts WHERE post_id = (?)", params["post_id"])
    end

    def insertcomment(params, user_id)
        db = getdb()
        db.execute("INSERT INTO comments(comment_author, comment_text, dislikecount, post_id ) VALUES (?,?,?,?)", user_id, params["comment_text"], 0, params["post_id"])
    end

    def updatepost(params)
        db = getdb()
        result = db.execute("UPDATE posts SET post_title = ?,post_text = ? WHERE post_id = ?",params["post_title"],params["post_text"],params["post_id"] )
    end

    # Gathers the information from the database to the editpost site.
    #
    # @param [Integer] post_id The post's ID
    # @param [Hash] params form data
    # @option params [String] post_title The title of the article
    # @option params [String] post_text The content of the article
    #
    # @return [Hash]
    #   * :error [Boolean] whether an error occured
    #   * :message [String] the error message
    def editpost(params)
        db = getdb()
        db.results_as_hash = true
        db.execute("SELECT post_id, post_title, post_text, author_id FROM posts WHERE post_id = ?", params["post_id"])
    end

    def validateifalreadythere(params, user_id)
        db = getdb()
        db.results_as_hash = true
        result = db.execute("SELECT * from likes WHERE author_id = ?", user_id)
        if result != nil
            return true
        else 
            return false
        end
    end
    # def likepost(params)
    #     db = getdb()
    #     result = db.execute("UPDATE posts SET dislikecounter = ((SELECT dislikecounter FROM posts WHERE post_id=?) + 1) WHERE post_id = ?", params["post_id"], params["post_id"] )
    #     "INSERT INTO likes SET likecounter = ((SELECT likecounter FROM likes WHERE post_like_id=?) + 1) WHERE post_like_id = ?"
        
    # end

    # def dislikepost(params)
    #     db = getdb()
    #     result = db.execute("UPDATE posts SET dislikecounter = ((SELECT dislikecounter FROM posts WHERE post_id=?) - 1) WHERE post_id = ?", params["post_id"], params["post_id"] )
    # end

    # def likecomment(params)
    #     db = getdb()
    #     result = db.execute("UPDATE comments SET dislikecount = ((SELECT dislikecount FROM comments WHERE comment_id=?) + 1) WHERE comment_id = ?", params["comment_id"], params["comment_id"] )
    # end

    # def dislikecomment(params)
    #     db = getdb()
    #     result = db.execute("UPDATE comments SET dislikecount = ((SELECT dislikecount FROM comments WHERE comment_id=?) - 1) WHERE comment_id = ?", params["comment_id"], params["comment_id"] )
    # end

    def likepost(params, user_id)
        db = getdb()
        result = db.execute("INSERT INTO likes (author_id, post_like_id ) VALUES (?,?)", user_id, params["post_id"])
    end

    def getlikes(params)
        db = getdb()
        likes = db.execute("SELECT * FROM likes WHERE post_like_id = ?", params["post_id"])
    end

    # Gets the posts that does have comments in them.
    #
    # @param [Hash] params form data
    # @param Input [String] Whatever the input may be that i
    #
    # @return [posts] if the information is correct
    def get_posts_with_comments(user_id)
        db = getdb()
        db.results_as_hash = true
        likes = db.execute("SELECT * FROM likes")
        comments = db.execute("SELECT * FROM comments")
        posts = db.execute("SELECT user.username, posts.post_id, post_title, post_text, posts.dislikecounter, author_id FROM posts INNER JOIN user on user.id = posts.author_id")
        posts.each do |post|
            post["comments"] = comments.select do |comment|
                comment["post_id"] == post["post_id"]
            end
            post["likes"] = likes.select do |like|
                like["post_like_id"] == post["post_id"] and like["author_id"] == user_id
            end
        end
        return posts
    end
end