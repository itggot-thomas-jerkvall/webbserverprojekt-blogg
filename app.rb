#result.first["Namn"] == params["name"] && 
require'slim'
require'sqlite3'
require'sinatra'
require 'byebug'
require 'BCrypt'
enable :sessions

#before do
#    if session
#end
get('/') do
    slim(:index)
end

#kolla att man är inloggad med Id inte namn!!
post('/log') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    result = db.execute("SELECT Id, username, password FROM users WHERE users.username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["password"]) == params["password"]
        session[:name] = result.first["username"]
        session[:Id] = result.first["Id"]
        redirect('/profile')
    else
        redirect('/')
    end
end

#
get('/profile') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    if session[:Id] == nil
        redirect('/')
    else
        result =  db.execute("SELECT Text, Images FROM profile WHERE User_Id = ?", session[:Id])
        
        slim(:profile, locals:{
            posts: result
        })
    end
end

post('/search') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    result = db.execute("SELECT Text, Images, username FROM profile INNER JOIN users ON profile.User_Id = users.Id WHERE users.username = ?", params["search"])
    
    slim(:searchedblogg, locals:{
        posts: result,
        first: result.first
        })
end

get('/edit') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    if session[:Id] == nil
        redirect('/')
    else
        result =  db.execute("SELECT Id, Text, Images FROM profile WHERE User_Id = ?", session[:Id])
        
        slim(:edit, locals:{
            posts: result
        })
    end
end

post('/edit/:id/delete') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    db.execute("DELETE FROM profile WHERE Id = ?", params["id"])

    redirect('/edit')
end

post('/addtext') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    db.execute("INSERT INTO profile(Text, Images, User_Id) VAlUES(?, ?, ?)", params["text"], params["image"], session[:Id])

    redirect('/profile')
end

get('/create') do
    slim(:create)
end

post('/created') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    hased_password = BCrypt::Password.create(params["password"])

    db.execute("INSERT INTO users(username, password) VAlUES(?, ?)", params["namn"], hased_password)

    redirect('/')
end

post('/logout') do
    session.destroy
    redirect('/')
end

get('/show') do
    if session[:Id] == nil
        redirect('/')
    else
        db = SQLite3::Database.new("db/Database.db")
        db.results_as_hash = true

        result =  db.execute("SELECT Id, username FROM users")
        
        slim(:show, locals:{
            profiles: result
        })
    end
end

post('/showprofile/:username') do
    if session[:Id] == nil
        redirect('/')
    else
        db = SQLite3::Database.new("db/Database.db")
        db.results_as_hash = true

        id = db.execute("SELECT Id FROM users WHERE username=?", params["username"])
        
        result =  db.execute("SELECT Id, Text, Images FROM profile WHERE User_Id = ?", id.first["Id"])
        
        username = {"username" => params["username"]}

        slim(:searchedblogg, locals:{
            posts: result,
            first: username
            })
    end
end