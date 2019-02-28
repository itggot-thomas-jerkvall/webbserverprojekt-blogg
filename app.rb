#result.first["Namn"] == params["name"] && 
require'slim'
require'sqlite3'
require'sinatra'
require 'byebug'
require 'BCrypt'
enable :sessions


get('/') do
    slim(:index)
end

post('/log') do
    db = SQLite3::Database.new("db/Database.db")
    db.results_as_hash = true

    result = db.execute("SELECT username, password FROM users WHERE users.username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["password"]) == params["password"]
        session[:name] = result.first["username"] 
        redirect('/profile')
    else
        redirect('/')
    end
end

get('/profile') do
    if session[:name] == nil
        redirect('/')
    else
        slim(:profile)
    end
end

get('/edit') do
    if session[:name] == nil
        redirect('/')
    else
        slim(:edit)
    end
end

post('/addtext') do
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