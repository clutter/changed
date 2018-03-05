# Changed

A gem for tracking what **changed** when.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'changed'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install changed
```

After installing the gem run the following to setup:

```bash
rails changed:install:migrations
rails db:migrate
```

## Usage

This gem is designed to integrate with active record objects:

```ruby
class Employee
  include Changed::Auditable
  belongs_to :company

  audited :name, :email, :eid, :company, transformations: { eid: 'Employee ID' }
end
```

To ensure the proper 'changer' is tracked add the following code to your application controller:

```ruby
before_action :configure_audit_changer

protected

def configure_audit_changer
  Changed.changer = User.current
end
```

To execute code with a different the timestamp or changer use the following:

```ruby
employee = Employee.find_by(name: "...")
Changed.perform(changer: User.current, timestamp: Time.now) do
  employee.name = "..."
  employee.save!
end
```

## Configuration

Specifying `default_changer_proc` gives a changer if one cannot be inferred otherwise:

```ruby
Changed.config.default_changer_proc = ->{ User.system }
```

## Status

[![CircleCI](https://circleci.com/gh/clutter/changed.svg?style=svg&circle-token=77cf2fadb88cfc6b16bf85643826152305dac75f)](https://circleci.com/gh/clutter/changed)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
