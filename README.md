# README

### Initializing application

Create a new Rails app and access the directory:
```
rails new livecoding -d postgresql
cd livecoding
```

Delete git folder and setup remote repository:
```
rm -r .git
git init
git remote add origin git@github.com:silaspedrosa/rails-live-coding.git
```

Commit the initial code and push to the repo:
```
git fetch
git add .
git commit “init”
git branch --set-upstream-to=origin/master master
git push -f
```

Basic DevOps:
```
create the 'Dockerfile' file for managing the container
create the 'capyba' file for the beautiful signature =D
create the 'CHECKS' file to configure deploy checking waiting time and amount of attempts
create the 'docker-compose.yml' file to help orchestrate different containers
create the 'DOKKU_SCALE' file to define the amount of resources needed to run the app
create the 'Procfile' file for setting how to actually run the app in production
create the 'app.json' file for configuring the post deploy scripts 
```

Database setup:
In the `config/database.yml`, add `url: <%= ENV['DATABASE_URL'] %>` to the default configuration
Change the enconding from `unicode` to `utf8` in the default configuration;
Leave the development configuration like this:
```
development:
  <<: *default
```
Leave the test configuration like this:
```
test:
  <<: *default
  # sub _development for _test or add _test
  url: <%= ENV['DATABASE_URL'].include?('development') ? ENV['DATABASE_URL'].sub('development','test') : ENV['DATABASE_URL'] + '_test' %>
```
Leave the production configuration like this:
```
production:
  <<: *default
```

Build from docker:
```
add "gem 'sidekiq',  '4.1.2'" to Gemfile to install the background job library
bundle install # do it outside docker in order to create a Gemfile.lock, but maybe just creating an empty Gemfile.lock would be enough
docker-compose build
```

Run the app:
```
docker-compose up
```

Open another terminal tab and access the docker container by:
`docker exec -it livecoding_app_1 /bin/bash`

Setup the database with:
```
rails db:create
raild db:migrate
```

Access the app from `localhost:3000` in any browser.

Time for a deploy! First, push the changes to the main repository.
```
git add .
git commit -m "app running"
git push
```
Then, let's add the dokku production remote for the deploys:
`git remote add production <production dokku remote>`
Now it's time for the actual deploy:
`git push production master:master`


### Authentication

Add the Devise gem to the Gemfile:
`gem 'devise'`
In the first terminal tab, stop the server and run `docker-compose build` again.
Start the server again with `docker-compose up`

In a second terminal tab, run the devise generator:
`rails generate devise:install`
Follow the generator instructions:
add `config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }` to `config/environments/development.rb`
place `root to: "home#index"` inside de `do...end` block of the `config/routes.rb` file
add to the `<body>` tag of `app/views/layouts/application.html.erb` the following tags:
```
<p class="notice"><%= notice %></p>
<p class="alert"><%= alert %></p>
```

Stop the first terminal and start it again (when you change files in the `config` folder you need to restart the server)
If you access the same url, you'll see some error about not having a `HomeController` constant. We just need to define one by creating the file `app/controllers/home_controller.rb` and placing the following code:
```
class HomeController < ApplicationController
end
```

If you try to acces the url again, you'll get another error complaining about not having the index action inside `HomeController`. We can solve that by defining it:
```
def index
end
```
If you try one more time, you'll get another error complaining about the lack of templates. To solve that, put this code in `app/view/home/index.html.erb`:
```
<h1>Home!</h1>
```

Now you have a dummy app that has devis installed, no database tables nor Models and a dummy index page. We need to generate the `User` model in order to actually implement the authentication system. For that, we can do:
`rails g devise user first_name last_name`

This command will create `app/models/user.rb` defining the user model, i.e. tha ORM mapping for the users table in the database. It'll also add user and authtentication routes to `/config/routes.rb`. You'll be able to notice a new migration file inside the `db/migrate` folder describing the new table creation.

Anytime you create a migration file, you must execute the migration before accessing the website again. So go to your second terminal tab, access the container and run the migrations:
`rails db:migrate`
After that, you'll be able to access the index page normally.

Now, we must demand that the user has logged in before accessing the index page. To achieve that we must
add `before_action :authenticate_user!` **after** the `protect_from_forgery with: :exception` line in `app/controllers/application_controller.rb`

If you try to access the website, you'll get an error. Our last command added new things to `config/routes.tb`, so we need to restart the server first. After that, you'll see the login page.
You'll also be able to check out the sign up page by following the link in the login page. If you fill the form and create a user, you'll be signed in as well and be redirected to the home page. Now we should create a sign out link! For that, you just need to place `<%= link_to('Sair', destroy_user_session_path, method: :delete) %>` in your index view.

At any time, you can open a second terminal tab, access the container and check out all the routes defined in your app. You just need to run the command
`rails routes`
and try do understand the output. It's not as hard as it looks like! :)

Everything should be working fine by now, but the user form in the sign up page doesn't include the fields `first_name` and `last_name`. If you search around yout project, you won't be able to find the view file that implements the page's HTML. Devise keeps default view files inside their own code, but they provide a simple way to override these views. Just run:
`rails generate devise:views`
and you'll see a bunch of new files implementing all the views regarding user management! Jump to `app/views/devise/registrations/new.html.erb` and edit the code to include the fields:
```
<h2>Sign up</h2>

<%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
  <%= render "devise/shared/error_messages", resource: resource %>

  <div class="field">
    <%= f.label :first_name %><br />
    <%= f.text_field :first_name, autofocus: true, autocomplete: "first_name" %>
  </div>

  <div class="field">
    <%= f.label :last_name %><br />
    <%= f.text_field :last_name, autofocus: true, autocomplete: "last_name" %>
  </div>

  <div class="field">
    <%= f.label :email %><br />
    <%= f.email_field :email, autocomplete: "email" %>
  </div>

  <div class="field">
    <%= f.label :password %>
    <% if @minimum_password_length %>
    <em>(<%= @minimum_password_length %> characters minimum)</em>
    <% end %><br />
    <%= f.password_field :password, autocomplete: "new-password" %>
  </div>

  <div class="field">
    <%= f.label :password_confirmation %><br />
    <%= f.password_field :password_confirmation, autocomplete: "new-password" %>
  </div>

  <div class="actions">
    <%= f.submit "Sign up" %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```

Cool! Now let's print the user's name in the home page so we can assure everything is working:
```
<%= link_to('Sair', destroy_user_session_path, method: :delete) %>
<h4>Welcome, <%= current_user.first_name %>!</h4>
<h1>Home!</h1>
```
Something is not right, because we still can't see the user's first name. Devise doesn't let you pass in any attributes you want in the user form. To allow more than the default ones (:email, :password and :password_confirmation), we'll to do some little thing in the application controller:
Add `before_action :configure_permitted_parameters, if: :devise_controller?` right after the class definition.
Add this to the end of the class definition:
```
protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
end
```
Now, if you register a new user you'll be able to see their name in the home screen! 



### Troubleshooting
If you ever face this issue while trying to bring the server up with `docker-compose up`:
```
app_1             | A server is already running. Check /app/tmp/pids/server.pid.
app_1             | => Booting Puma
app_1             | => Rails 5.1.7 application starting in development 
app_1             | => Run `rails server -h` for more startup options
app_1             | Exiting
livecoding_app_1 exited with code 1
```
you just need to delete the pid file by running
`rm tmp/pids/server.pid`



This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
