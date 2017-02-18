%w[
  version
].each { |file| require_relative "mores/#{file}" }

[
  [Mores,        :BlockInitialize, 'block_initialize'],
  [Mores,        :LinkedList,      'linked_list'     ],
  [Mores,        :Succession,      'succession'      ],
  [Mores,        :ImmutableStruct, 'immutable_struct'],
].each { |(mod, name, file)| mod.autoload name, "mores/#{file}" }
