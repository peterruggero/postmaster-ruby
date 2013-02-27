# Postmaster

Developer Friendly Shipping

Postmaster takes the pain out of sending shipments via UPS, Fedex, and USPS.
Save money before you ship, while you ship, and after you ship.

https://www.postmaster.io/

## Requirements

- [Ruby](http://www.ruby-lang.org/) 1.8.7 or above.
- [rest-client](https://github.com/archiloque/rest-client) 1.4 or above.
- [multi_json](https://github.com/intridea/multi_json) 1.0.2 or above.

## Installation

You can install using [gem](#gem) or from [source](#source). 

### Gem

Add this line to your application's Gemfile:

    gem 'postmaster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install postmaster
    
### Source

Download the postmaster-ruby source:

    $ git clone https://github.com/postmaster/postmaster-ruby

If you want to build the gem from source:

    $ cd postmaster-ruby
    $ gem build postmaster.gemspec

## Usage

See https://www.postmaster.io/docs for tutorials and documentation.

## Issues

Please use appropriately tagged github [issues](https://github.com/postmaster/postmaster-api/issues) 
to request features or report bugs.

## Testing
    
    $ cd tests
    $ PM_API_KEY=your-api-key rake test
