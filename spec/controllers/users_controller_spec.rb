require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
      
    end
    
    it "should be successful" do
      get :show, :id => @user
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end
    
    it "should have the profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
    
    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quuux")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end
  end

  describe "GET 'new'" do
    
    before(:each) do
      get :new
    end
    
    it "should be successful" do
      response.should be_success
    end
    
    it "should have the right title" do
      response.should have_selector("title", :content => "Sign up")
    end
    
    it "should have the name field" do
      response.should have_selector("input[name='user[name]'][type='text']")
    end
    
    it "should have an email field" do
      response.should have_selector("input[name='user[email]'][type='text']")
    end
    
    it "should have a password field" do
      response.should have_selector("input[name='user[password]'][type='password']")
    end
    
    it "should have a confirmation field" do
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
    
    describe "for signed in user" do
      
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should forward the user to his home page" do
        get :new
        response.should redirect_to(@user)
      end
      
      it "should display a hint because of restriction" do
        get :new
        flash[:notice].should =~ /Page unavailable/i
      end
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end
      
      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end
      
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
    end
    
    describe "success" do
      
      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com", :password => "foobar",
                  :password_confirmation => "foobar" }
      end
      
      it "should create a new user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end 
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
      get :edit, :id => @user
    end
    
    it "should be succesful" do
      response.should be_success
    end
    
    it "should have the right title" do
      response.should have_selector("title", :content => "Edit user")
    end
    
    it "should have a link to change the gravatar" do
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url, 
                                         :content => "change")
    end
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before(:each) do
        @invalid_attr = { :eamil => "", :name => "" }
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @invalid_attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @invalid_attr
        response.should have_selector("title", :content => "Edit user")
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.com", 
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end
      
      it "should change the user's attribute" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should   == user.name
        @user.email.should  == user.email
      end
      
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update pages" do
    before(:each) do 
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'update'" do
        get :update, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed-in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "bob@example.com", :name => "Foo the Bar" )
        test_sign_in(wrong_user)
      end
      
      it "should require the matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        get :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second  = Factory(:user, :email => "foobar@foobar.com", :name => "Foo bar 1")
        third   = Factory(:user, :email => "foobar2@foobar.com", :name => "Foo bar 2")

        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email), :name => Factory.next(:name))
        end
      end

      it "should be succesful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2", 
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2", 
                                           :content => "Next")
      end
      
      it "the delete links should not be visible" do
        get :index
        response.should_not have_selector("a", :content => "delete")
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    
    
    describe "as an admin user" do
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :name => "Admin User",  :admin => true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
      
      it "should NOT let delete themselves(!)" do
        lambda do
          delete :destroy, :id => @admin
          flash[:error].should =~ /You should not delete yourself.../i
          response.should redirect_to(users_path)
        end.should_not change(User, :count).by(-1)
      end
    end
  end
end
