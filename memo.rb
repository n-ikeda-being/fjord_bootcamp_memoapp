# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class Memo
  # dbに接続
  def initialize
    db = 'mydb'
    host = 'localhost'
    user = 'username'
    password = 'password'
    port = 5432
    @connect = PG::Connection.new(host: host, port: port, dbname: db, user: user, password: password)
  end

  def list
    @connect.exec('SELECT * FROM memodates ORDER BY id')
  end

  def write(new_id, title, content)
    @connect.exec('INSERT INTO memodates VALUES ($1, $2, $3)', [new_id, title, content])
  end

  def update(id, title, content)
    @connect.exec('update memodates set title=$2, content=$3 where id=$1', [id, title, content])
  end

  def delete(id)
    @connect.exec('delete from memodates where id=$1', [id])
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
  @memo = memo.list.find { |date| date['id'] == params['id'] }
  @pagename = '内容表示'
  erb :show
end

# 新規作成したメモを投稿
post '/memos' do
  @memos = memo.list

  id = @memos.map { |date| date['id'].to_i }
  new_id = (id.max + 1)
  memo.write(new_id, params['title'], params['content'])
  redirect '/memos'
end

# 特定のメモの編集画面
get '/memos/:id/edit' do
  @memo = memo.list.find { |date| date['id'] == params['id'] }
  @pagename = '編集'
  erb :edit
end

# 編集したメモを投稿
patch '/memos/:id' do
  memo.update(params['id'], params['title'], params['content'])
  @memos = memo.list

  redirect "/memos/#{params[:id]}"
end

# 特定のメモを削除
delete '/memos/:id' do
  memo.delete(params['id'])

  redirect '/memos'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
