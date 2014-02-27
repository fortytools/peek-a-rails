peek-a-rails
============

Rails monitoring watch observer.

Peek-a-Rails is a Redis-backed Rails engine which watches
and observes your Rails app and gathers several metrics.
It comes fully loaded with a nice web interface where you
can check the health of your app at a glance.

## Requirements

Tested with Ruby 2.1, Rails 4 and Redis 2.8. Other versions might
work as well.

## Installation

In your `Gemfile`:

    gem 'peek-a-rails'

## Getting Started

Generate initializer:

    rails generate peek-a-rails:install

Mount the web interface in `config/routes.rb`:

    mount Peekarails::Engine, at: "peek"

## Configuration

See options in `config/initializers/peekarails.rb`.

At the very least, you might want to configure the Redis
connection in the initializer.

## Contributing

Fork, Pull Request, Profit.

## License

MIT License. Copyright 2014 fortytools. http://fortytools.com
