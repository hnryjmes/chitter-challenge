require 'pg'
require_relative 'password'

include Password

class User

  def self.check_password(username, password)
    user = User.find_by_username(username)
    if test_password(password, user.password)
      return true
    else
      return false
    end
  end

  def self.find_by_username(username)
    User.all.each do |user|
      if user.username == username
        return user
      end
    end
  end

  def self.check_if_unique(username, email)
    User.all.each do |user|
      return false if user.username == username
      return false if user.email == email
    end
    true
  end

  def self.create(name:, username:, email:, password:)
    if ENV['ENVIRONMENT'] == 'test'
      connection = PG.connect(dbname: 'chitter_test')
    else
      connection = PG.connect(dbname: 'chitter')
    end

    hashed = hash_password(password)

    result = connection.exec("INSERT INTO users (name, username, email, password) VALUES('#{name}', '#{username}', '#{email}', '#{hashed}') RETURNING name, username, email, password;")

    User.new(name: result[0]['name'], username: result[0]['username'], email: result[0]['email'], password: result[0]['password'])
  end

  def self.all
    if ENV['ENVIRONMENT'] == 'test'
      connection = PG.connect(dbname: 'chitter_test')
    else
      connection = PG.connect(dbname: 'chitter')
    end
    result = connection.exec("SELECT * FROM users")
    result.map do |user|
      User.new(name: user['name'], username: user['username'], email: user['email'], password: user['password'])
    end
  end

  def initialize(name:, username:, email:, password:)
    @name = name
    @username = username
    @email = email
    @password = password
  end

  attr_reader :name, :username, :email, :password
end
