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
