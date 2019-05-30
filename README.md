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

If you try to access the website, you'll get an error. As you were not authenticated yet, you were going to be redirected to the login page, but as we don't have that yet, we get an error.


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
