require File.dirname(__FILE__) + '/../test_helper'
require 'errors_controller'

# Re-raise errors caught by the controller.
class ErrorsController; def rescue_action(e) raise e end; end

class ErrorsControllerTest < Test::Unit::TestCase
  fixtures :errors

  def setup
    @controller = ErrorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:errors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_error
    old_count = Error.count
    post :create, :error => { }
    assert_equal old_count+1, Error.count
    
    assert_redirected_to error_path(assigns(:error))
  end

  def test_should_show_error
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_error
    put :update, :id => 1, :error => { }
    assert_redirected_to error_path(assigns(:error))
  end
  
  def test_should_destroy_error
    old_count = Error.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Error.count
    
    assert_redirected_to errors_path
  end
end
