%w[
  version
  block_initialize
  linked_list
  succession
  immutable_struct
].each { |file| require "mores/#{file}" }
