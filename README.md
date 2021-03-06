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
Edit the line in `config/environments/production` to always enable public files serving: 
`config.public_file_server.enabled = true`

```
create the 'Dockerfile' file for managing the container
create the 'capyba' file for the beautiful signature =D
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

#### Finishing up deploy settings
When the deploy is done, the  deploy script has to test if the server is alive, so we implement this action in the `app/controllers/application_controller.rb`:
```
def check_deploy
  render json: "deploy_successful"
end
```
We also have to place this route in the end of `config/routes.rb`:
`get "check_deploy", controller: 'application'`


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

#### DevOps for future deploys
Make sure you uncomment the  `config.secret_key = ...` line in the `config/initializers/devise.rb` file.

### A little bit of UI
Let's improve just a little bit the look n' feel of the app. First, add the bootstrap files to the application layout:
```
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
```
Maybe you should store them in your own infrasctructure, maybe you should provide them from your own CDN, maybe you should just place direct links to their CDN. Do a little research about it!

Rename `app/assets/stylesheets/application.css` to `app/assets/stylesheets/application.css.scss` so we can leverage the use o sass.

Let's use the `Raleway` font just to try something new. To achieve that, include the font in your application layout header (again, read a little more to know the pros and cons about directly including fonts from external CDNs):
`<link href="https://fonts.googleapis.com/css?family=Raleway:300,400,700&display=swap" rel="stylesheet">`

Let's jump into our new application stylesheet (`app/assets/stylesheets/application.css.scss`) and prepare the ground for future work. 

To the end of the file, add
```
$grey-color: #ebebeb;
$white-color: white;
$black-color: black;
$base-color: $grey-color;
$border-color: rgba(150, 150, 150, 0.5);
$front-color: $white-color;

.bg-base {
    background-color: $base-color;
}

.bg-front {
    background-color: $front-color;
}
```
so we can establish some basic color variables and background coloring classes for later use. Then, basic html setup so we can make use of the whole screen:
```
body,
html {
    width: 100%;
    height: 100%;
}
```
Now, let's all elements use the font we included:
```
* {
    font-family: 'Raleway', sans-serif;
}
```
Then, define some basic utility classes:
```
.full-width {
    width: 100%;
}

.full-height {
    height: 100%;
}

.font-size-08 {
    font-size: 0.8rem;
}

.font-size-12 {
    font-size: 1.2rem;
}
```

Now, let's improve our login page `app/views/devise/sessions/new.html.erb`:
```
<div class="full-width full-height container">
  <div class="row justify-content-center">
    <div class="container bg-front p-5" style="width: 600px">
      <div class="row">
        <div class="col">
          <h2>LOG IN</h2>
        </div>
      </div>
      <!-- form will go here -->
      </div>
  </div>
</div>
```
This still doesn't do much, but we have setup the baseground for placing our form. The code for ther form is:
```
<%= form_for(resource, as: resource_name, url: session_path(resource_name), html: { class: 'd-flex flex-column form' }) do |f| %>
  <div class="field mt-3 full-width">
    <%= f.label :email, class: 'font-size-12' %><br />
    <%= f.email_field :email, autofocus: true, autocomplete: "email", class: 'full-width text-input' %>
  </div>

  <div class="field mt-3 full-width">
    <%= f.label :password, class: 'font-size-12' %><br />
    <%= f.password_field :password, autocomplete: "current-password", class: 'full-width text-input' %>
  </div>

  <% if devise_mapping.rememberable? %>
    <div class="field mt-3 font-weight-light">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me, class: 'font-size-08' %>
    </div>
  <% end %>

  <div class="actions">
    <%= f.submit "Log in", class: 'btn btn-primary pl-5 pr-5 font-weight-bold' %>
  </div>
<% end %>

<%= render "devise/shared/links" %>
```
Almost done! We just have to define some classes to style the fields:
```
.form .field .text-input {
    height: 55px;
    width: 100%;
    border: 1px solid $border-color;
}

.form .field input[type="checkbox"] {
    border: 1px solid $border-color !important;
}

.form .field .actions input[type="submit"] {
    background-color: $black-color;
    height: 2.5rem;
}
```
Done! Nothing fancy, but it looks live already!
Now, you can just simply repeat it all for the sign up form in `app/views/registrations/new.html.erb`:
```
<div class="full-width full-height container">
  <div class="row justify-content-center">
    <div class="container bg-front p-5" style="width: 600px">
      <div class="row">
        <div class="col">
          <h2>SIGN UP</h2>
        </div>
      </div>

      <%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: { class: 'd-flex flex-column form' }) do |f| %>
        <div class="field mt-3">
          <%= f.label :first_name %><br />
          <%= f.text_field :first_name, autofocus: true, autocomplete: "first_name", class: "text-input" %>
        </div>

        <div class="field mt-3">
          <%= f.label :last_name %><br />
          <%= f.text_field :last_name, autocomplete: "last_name", class: "text-input" %>
        </div>

        <div class="field mt-3">
          <%= f.label :email %><br />
          <%= f.email_field :email, autocomplete: "email", class: "text-input" %>
        </div>

        <div class="field mt-3">
          <%= f.label :password %>
          <% if @minimum_password_length %>
          <em>(<%= @minimum_password_length %> characters minimum)</em>
          <% end %><br />
          <%= f.password_field :password, autocomplete: "new-password", class: "text-input" %>
        </div>

        <div class="field mt-3">
          <%= f.label :password_confirmation %><br />
          <%= f.password_field :password_confirmation, autocomplete: "new-password", class: "text-input" %>
        </div>

        <div class="actions">
          <%= f.submit "Sign up", class: 'btn btn-primary pl-5 pr-5 font-weight-bold mt-5' %>
        </div>
      <% end %>

      <%= render "devise/shared/links" %>
    </div>
  </div>
</div>
```

#### Navigation
Let's improve the navigation for further pages and prepare the home page for the content part. Place this in the home page view:
```
<div class="container">
  <div class="row justify-content-between">
    <h4>Bem-vindo, <%= current_user.first_name %>!</h4>
    <nav class="nav row">
      <%= link_to "Home", root_path, class: current_page?(root_path) ? 'nav-link bg-primary text-light' : 'nav-link'  %>
      <%= link_to('Sair', destroy_user_session_path, method: :delete, class: "nav-link") %>
    </nav>
  </div>
  <div class="row">
    <h1>Home!</h1>
  </div>
</div>
```
For now, it's pointless, as we only have one route, but later on we'll more modules in our app.

Comment these lines in `app/assets/stylesheets/scaffolds.scss` because it makes the links really ugly:
```
// a {
//   color: #000;
//   &:visited {
//     color: #666;
//   }
//   &:hover {
//     color: #fff;
//     background-color: #000;
//   }
// }
```

### Incomes module
Let's leverege the magic of the rails scaffold and generate the complete module with:
`rails g scaffold Income value:float date:date`
If you try to access any page now, you get an error because you didn't run the migrations. Run them and the app will be back to normal.
Let's add an entry to our navigation bar so we can access the newly created module:
`<%= link_to "Receitas", incomes_path, class: current_page?(incomes_path) ? 'nav-link bg-primary text-light' : 'nav-link'  %>`

Experiment taking a look at the new views and do some translations. Also, add `class="table"` to the table tag in the index view so you can have a bootstrap table.

### Navigation bar in all screens
In our application layout, we'll do some reasoning about the user being logged in or not. If it is, we'll draw the navigation bar and setup the space for inner content so the child views do not need to worry about his. If it's not logged in, we'll do nothing and delegate the rendering to the devise views. So, replace the body of the application layout for this:
```
<body class="bg-base">
    <% if !user_signed_in? %>
      <%= yield %>
    <% else %>
      <div class="container">
        <div class="row justify-content-between">
          <h4>Bem-vindo, <%= current_user.first_name %>!</h4>
          <nav class="nav row">
            <%= link_to "Home", root_path, class: current_page?(root_path) ? 'nav-link bg-primary text-light' : 'nav-link'  %>
            <%= link_to "Receitas", incomes_path, class: current_page?(incomes_path) ? 'nav-link bg-primary text-light' : 'nav-link'  %>
            <%= link_to('Sair', destroy_user_session_path, method: :delete, class: "nav-link") %>
          </nav>
        </div>
        <%= yield %>
      </div>
    <% end %>
  </body>
```
In our home page, let's just leave this:
```
<div class="row">
  <h1>Home!</h1>
</div>
```

### Expenses module
Time for another module!
`rails g scaffold Expense value:float date:date`
Add a menu entry:
`<%= link_to "Receitas", incomes_path, class: current_page?(incomes_path) ? 'nav-link bg-primary text-light' : 'nav-link'  %>`
Run the migration and check out the result.

For the generated table, experiment using the bootstrap classes `table table-striped`.

### Dashboard
Let's add the information about our overall cash balance in the home page:
`<h3>Caixa: </h3>`
But how can we place an actual value inside the html? We should get it from our controller, so  the view can be:
`<h3>Caixa: <%= @cash_balance %></h3>`
It still doesn't show because the variable is not being assigned yet. Go to the controller action in `app/controllers/home_controller.rb#index` and place the code:
```
total_expenses = Expense.sum(:value)
total_incomes = Income.sum(:value)
@cash_balance = total_incomes - total_expenses
```
OK! Now we need to make it look like currency with the helper `number_to_currency`:
`<h3>Caixa: <%= number_to_currency @cash_balance %></h3>`

### Charts
Install the gem `chartkick` and restart your server. Then, add this
```
//= require chartkick
//= require Chart.bundle
```
to `app/assets/javascripts/application.js`, right before `//= require_tree .`.

In the home index action, we'll group the expenses by month and sum their values. The same will be done with the incomes. We must  normalize the data because it is possible that, in some month, no expenses or no incomes were registered, so there would be no  data. As we want to show them together, we need to fill with zeroes the empty months. Last but not least, we must sum the values from the prior two charts to result in the total balance chart.

The home controller would be like this:
```
class HomeController < ApplicationController
  def index
    total_expenses = Expense.sum(:value)
    total_incomes = Income.sum(:value)
    @cash_balance = total_incomes - total_expenses

    expenses_by_month = Expense.group("(extract(year from date))::integer").group('(EXTRACT(MONTH FROM date))::integer').sum(:value)
    incomes_by_month = Income.group("(extract(year from date))::integer").group('(EXTRACT(MONTH FROM date))::integer').sum(:value)
    normalize_charts_keys expenses_by_month, incomes_by_month
    balance_by_month_map = {}

    incomes_by_month.keys.each do |key|
      balance_by_month_map[key] = incomes_by_month[key] - expenses_by_month[key]
    end

    prepared_expenses_by_month = prepare_keys(expenses_by_month)
    prepared_incomes_by_month = prepare_keys(incomes_by_month)
    prepared_balance_by_month = prepare_keys(balance_by_month_map)

    @expenses_incomes_data = [
      {name: "Receitas", data: prepared_incomes_by_month},
      {name: "Despesas", data: prepared_expenses_by_month},
    ]
    @balance_data = prepared_balance_by_month

    respond_to do |format|
      format.html { render }
      format.json { render json: { 
        cash_balance: ActionController::Base.helpers.number_to_currency(@cash_balance),
        expenses_incomes_data: @expenses_incomes_data,
        balance_data: @balance_data
       }}
    end
  end

  private
    def normalize_charts_keys(chart1, chart2)
      chart1.keys.each do |key|
        chart2[key] = 0 unless chart2.has_key? key
      end
      chart2.keys.each do |key|
        chart1[key] = 0 unless chart1.has_key? key
      end
    end

    def prepare_keys(hash)
      months = %w(Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez) 
      hash
        .keys
        .sort
        .map do |key|
          value = hash[key]
          ["#{months[key[1] - 1]}/#{key[0]}", value]
        end
    end
end
```

And the view would have this code in order to actually show the charts:
```
<div class="row mt-5">
  <h3>Caixa atual: <span id="cashBalance"><%= number_to_currency @cash_balance %></span></h3>
</div>
<div class="row">
  <div class="col">
    <%= line_chart @expenses_incomes_data, id: "expenses_income", prefix: "R$" %>
  </div>
</div>
<div class="row mt-5">
  <div class="col">
    <%= column_chart @balance_data, id: "balance", prefix: "R$", ytitle: "Balanço" %>
  </div>
</div>
``` 

You should be able to see the charts now. However, they're not live yet.

### Long polling
For now, we'll stick to long polling as webockets are a bit trickier to implement and setup, specially in production. Long  polling consists of making requests from time to time. It's a simpler approach because it ends up wasting resources with requests that won't bring any new data.

Create the file `app/assets/javascripts/home.js` and place the following code:
```
(function() {
    'use strict';

    function dashboardRequest() {
        Rails.ajax({
            url: '/',
            type: 'get',
            data: {},
            dataType: 'json',
            beforeSend: () => true,
            success: (data) => {
                try {
                    const expensesIncome = Chartkick.charts["expenses_income"];
                    const balance = Chartkick.charts["balance"];
                    expensesIncome.updateData(data.expenses_incomes_data);
                    balance.updateData(data.balance_data);
                } catch (error) {
                    console.error(error);
                } finally {
                    setTimeout(dashboardRequest, 1000);
                }
            },
            error: (error) => console.log(error)
        });
    }
    dashboardRequest();
})()
```
It simply make a request that, in the end, sets a timeout to call itself again. In the success callback, it accesses the charts and updates their data.

To test it, you can leave the home page open and open the expenses link in a new tab. If you add a  new expense, you'll see the chart changing right away.


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
