%w[
  version
].each { |file| require_relative "mores/#{file}" }

module Mores
  module Patch end
end

[
  [Mores::Patch, :FileUtils,       'patch/file_utils'],
  [Mores,        :BlockInitialize, 'block_initialize'],
  [Mores,        :LinkedList,      'linked_list'     ],
  [Mores,        :Succession,      'succession'      ],
  [Mores,        :ImmutableStruct, 'immutable_struct'],
].each { |(mod, name, file)| mod.autoload name, "mores/#{file}" }
