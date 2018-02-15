require 'request_store'

require 'changed/auditable'
require 'changed/builder'
require 'changed/config'
require 'changed/engine'

module Changed
  Field = Struct.new(:was, :now, :name)
  Relationship = Struct.new(:associations, :name)

  # Access the library configuration.
  #
  # ==== Examples
  #
  #    Changed.config.default_changer_proc = ->{ User.system }
  def self.config
    @config ||= Config.new
  end

  # Access the timestamp (this value is set as the timestamp within an audit and defaults to now).
  def self.timestamp
    options[:timestamp] || Time.now
  end

  # Customize the timestamp (uses a request store to only change lifeycle event).
  #
  # ==== Attributes
  #
  # * +timestamp+ - A timestamp to use.
  #
  # ==== Examples
  #
  #    Changed.timestamp = 2.hours.ago
  def self.timestamp=(timestamp)
    options[:timestamp] = timestamp
  end

  # Access the changer (this value is set as the changer within an audit and defaults to config).
  def self.changer
    options[:changer] || config.default_changer_proc&.call
  end

  # Customize the changer (uses a request store to only change lifeycle event).
  #
  # ==== Attributes
  #
  # * +changer+ - A changer to use.
  #
  # ==== Examples
  #
  #    Changed.changer = User.current
  def self.changer=(changer)
    options[:changer] = changer
  end

  # Perform a block with custom override options.
  #
  # ==== Attributes
  #
  # * +options+ - Values for the changer and / or timestamp.
  # * +block+ - Some code to run with the new options.
  #
  # ==== Examples
  #
  #    Changed.perform(changer: User.system, timestamp: 2.hours.ago) do
  #      widget.name = "Sprocket"
  #      widget.save!
  #    end
  def self.perform(options = {}, &block)
    backup = self.options
    self.options = options
    block.call
  ensure
    self.options = backup
  end

  OPTIONS_REQUEST_STORE_KEY = :changed_options
  private_constant :OPTIONS_REQUEST_STORE_KEY

  def self.options=(options)
    RequestStore.store[OPTIONS_REQUEST_STORE_KEY] = options
  end

  def self.options
    RequestStore.store[OPTIONS_REQUEST_STORE_KEY] ||= {}
  end
end
