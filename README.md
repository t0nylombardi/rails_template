# Rails Template

A Rails template for starting new Rails projects

## Introduction

This Rails template sets up A Rails project with Docker, Rspec, Devise, and Tailwind. 

## Requirements
- Docker 
- Ruby 3.x and above
- Rails 7.0.x and above

## Initial Installation
 
 `$ rails new your-app --skip-bundle -d <postgresql, mysql, sqlite3> -m https://raw.githubusercontent.com/t0nylombardi/rails_template/default.rb`

Replace `your-app` with the name of your application.

### For booting up the app

run `docker-compose up --build`

### For entering the shell of the app

Run `docker-compose run app bash`. This will drop you into the container where the app is located.

Note that you should run `docker-compose up` in a separate terminal window so that the database and all related services are booted up already.

## Contributing

Feel free to fork this and create pull requests. We adhere to the Code of Conduct [as described for participation on GitHub](https://docs.github.com/en/site-policy/github-terms/github-event-code-of-conduct). Please be nice to one another.

## License

This code is released under the [MIT License](https://opensource.org/licenses/MIT).
