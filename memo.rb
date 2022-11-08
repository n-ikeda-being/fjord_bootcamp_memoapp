# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

FILE_PATH = 'public/memos.json'

def get_memos(file_path)
  File.open(file_path, 'r') { |f| JSON.parse(f.read) }
end

def write_memos(file_path, memos)
  File.open(file_path, 'w') { |f| JSON.dump(memos, f) }
end

class Memo

  def initialize
    db = 'mydb'
    host = 'localhost'
    user ='username'
    password = 'password'
    port = 5432
    @connect = PG::Connection.new(host: host, port: port, dbname: db, user: user, password: password)
  end

  def list
    results = @connect.exec("SELECT * FROM memodates" )
  end

end

memo = Memo.new


get '/' do
  redirect '/memos'
end

# トップ画面
get '/memos' do
  @memos = memo.list
  @pagename = 'メモ一覧'
  erb :index
end

# 新規作成画面
# /memos/newの前に /memos/:idの処理を持ってくるとnewもid扱いされたため順番に注意
get '/memos/new' do
  @pagename = '新規作成'
  erb :new
end

# 特定のメモの内容を表示する画面
get '/memos/:id' do
  memos = get_memos(FILE_PATH)
  @memo = memos[params[:id]]
  @pagename = '内容表示'
  erb :show
end

# 新規作成したメモを投稿
post '/memos' do
  title = params[:title]
  content = params[:content]

  memos = get_memos(FILE_PATH)
  id = (memos.keys.map(&:to_i).max + 1).to_s
  memos[id] = { title: title, content: content }

  write_memos(FILE_PATH, memos)

  redirect '/memos'
end

# 特定のメモの編集画面
get '/memos/:id/edit' do
  memos = get_memos(FILE_PATH)
  @memo = memos[params[:id]]
  @pagename = '編集'
  erb :edit
end

# 編集したメモを投稿
patch '/memos/:id' do
  title = params[:title]
  content = params[:content]

  memos = get_memos(FILE_PATH)
  memos[params[:id]] = { title: title, content: content }
  write_memos(FILE_PATH, memos)

  redirect "/memos/#{params[:id]}"
end

# 特定のメモを削除
delete '/memos/:id' do
  memos = get_memos(FILE_PATH)
  memos.delete(params[:id])
  write_memos(FILE_PATH, memos)

  redirect '/memos'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end