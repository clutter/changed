require 'request_store'

require 'changed/auditable'
require 'changed/builder'
require 'changed/engine'

module Changed
  Field = Struct.new(:was, :now, :name)
  Relationship = Struct.new(:associations, :name)

  def self.timestamp
    options[:timestamp] || Time.now
  end

  def self.timestamp=(timestamp)
    options[:timestamp] = timestamp
  end

  def self.changer
    options[:changer]
  end

  def self.changer=(changer)
    options[:changer] = changer
  end

  def self.config(options = {}, &block)
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
