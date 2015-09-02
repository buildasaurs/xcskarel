
require 'set'

module XCSKarel
  module Filter
    # returns a copy of the passed-in hash with only the provided keypaths kept
    # e.g. "name" will keep the key "name" at the top level.
    # supports even nested keypaths
    def self.filter_key_paths(object, key_paths)

      # array?
      if object.is_a?(Array)
        return self.filter_array(object, key_paths)
      end

      # hash?
      if object.is_a?(Hash)
        new_hash = Hash.new
        unique_key_paths = Set.new(key_paths)
        object.each do |k,v|

          keys = k.split('.') # key-paths must be separated by a period
          match = unique_key_paths.select do |key|
            key.split('.').first == keys.first
          end.first
          if match
            child_key_paths = match.split('.').drop(1)
            # if there are no more key paths, we just take everything (whitelisted by default)
            new_hash[keys.first] = child_key_paths.count == 0 ? v : filter_key_paths(v, child_key_paths)
          end
        end
        return new_hash
      end

      # object?
      return object
    end

    private

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
end