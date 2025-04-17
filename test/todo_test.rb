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

  def test_load_home_page
    get "/"
    assert_equal 302, last_response.status

    get last_response['location']
    assert_equal 200, last_response.status
  end

  def test_creating_list_with_invalid_names
    post "/lists", { list_name: "" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "List name must be between 1 and 100 characters."

    post "/lists", { list_name: "groceries" }
    post "/lists", { list_name: "groceries" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "List name must be unique."
  end

  def test_viewing_all_lists #get "/lists"
    #test focusing on the front end implementation
    post "/lists", { list_name: "groceries" }
    assert_equal 302, last_response.status

    get last_response['location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<h2>groceries</h2>"
  end

  def test_session_lists_structure #get "/lists"
    #test focusing on the back end implementation
    post "/lists", { list_name: "groceries" }

    lists = last_request.session[:lists]
    assert_instance_of Array, lists
    assert_equal 1, lists.size
    assert_equal "groceries", lists.first[:name].downcase
  end

  def test_creating_a_new_valid_list
    post "/lists", { list_name: "groceries" }

    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The list has been created."
    assert_includes last_response.body, "groceries"
  end

  def test_removing_a_list
    post "/lists", { list_name: "groceries" }

    post "/lists/1/destroy"
    assert_equal 302, last_response.status

    get last_response['location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "The list has been deleted."
  end

  def test_updating_a_list
    post "/lists", { list_name: "groceries" }
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The list has been created."
    assert_includes last_response.body, "groceries"

    post "/lists/1", { list_name: "wines"}
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The list has been updated."
    assert_includes last_response.body, "wines"
  end

  def test_adding_a_todo_to_a_list
    post "/lists", { list_name: "groceries" }

    post "/lists/1/todos", { todo: "red wine"}
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The todo was added."
    assert_includes last_response.body, "red wine"
  end

  def test_removing_todo_from_list
    post "/lists", { list_name: "groceries" }
    post "/lists/1/todos", { todo: "red wine"}
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The todo was added."
    assert_includes last_response.body, "red wine"

    post "/lists/1/todos/1/destroy"
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The todo has been deleted."
  end

  def test_updating_todo_status
    post "/lists", { list_name: "groceries" }
    post "/lists/1/todos", { todo: "red wine"}
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The todo was added."
    assert_includes last_response.body, "red wine"

    post "/lists/1/todos/1", { completed: true }
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "The todo has been updated"
  end

  def test_mark_list_todos_as_completed
    post "/lists", { list_name: "groceries" }
    post "/lists/1/todos", { todo: "red wine"}
    post "/lists/1/todos", { todo: "white wine"}

    post "lists/1/complete_all"
    assert_equal 302, last_response.status
    get last_response['location']
    assert_equal 200, last_response.status

    assert_includes last_response.body, "All todos have been completed."
  end

end