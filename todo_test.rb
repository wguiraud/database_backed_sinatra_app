require 'minitest/autorun'
require 'rack/test'
require 'pry'

require_relative 'todo'

class TodoTest < Minitest::test
  require Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup

  end

  def teardown

  end


end