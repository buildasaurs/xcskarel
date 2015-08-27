
require 'set'

module xcskarel
  # returns a copy of the passed-in hash with only the provided keypaths kept
  # e.g. "name" will keep the key "name" at the top level.
  # TODO: support even nested keypaths
  def self.filter_key_paths(hash, key_paths)
    new_hash = Hash.new
    keys = Set.new(key_paths)
    hash.each do |k,v|
      if keys.member?(k)
        new_hash[k] = v
      end
    end
    return new_hash
  end

  # filters each element
  def self.filter_array(array, key_paths)
    new_array = Array.new
    keys = Set.new(key_paths)
    array.each do |i|
      new_array << filter_key_paths(i, key_paths)
    end
    return new_array
  end
end