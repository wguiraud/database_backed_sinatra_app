require 'minitest/autorun'
require 'rack/test'
require 'pry'

ENV['RACK_ENV'] = 'test'

require_relative '../todo'

class TodoTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_loading_home_page
    get "/"
    assert_equal 302, last_response.status

    get last_response['location']
    assert_equal 200, last_response.status
  end

  def test_viewing_all_lists
    #test focusing on the front end implementation
    post "/lists", { list_name: "groceries" }
    assert_equal 302, last_response.status

    get last_response['location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<h2>groceries</h2>"
  end

  def test_session_lists_structure
    #test focusing on the back end implementation
    post "/lists", { list_name: "groceries" }

    lists = last_request.session[:lists]
    assert_instance_of Array, lists
    assert_equal 1, lists.size
    assert_equal "groceries", lists.first[:name].downcase
  end

  def test_load_list




  end

end