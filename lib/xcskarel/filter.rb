
require 'set'

module XCSKarel
  module Filter
    # returns a copy of the passed-in hash with only the provided keypaths kept
    # e.g. "name" will keep the key "name" at the top level.
    # supports even nested keypaths
    def self.filter_key_paths(object, key_paths, custom_block=nil)

      # array?
      if object.is_a?(Array)
        return self.filter_array(object, key_paths, custom_block)
      end

      # hash?
      if object.is_a?(Hash)
        new_hash = Hash.new
        unique_key_paths = Set.new(key_paths)
        object.each do |k,v|

          next if !custom_block.nil? && !custom_block.call(k, v)

          keys = k.split('.') # key-paths must be separated by a period
          matches = unique_key_paths.select do |key|
            kp = key.split('.')
            kp.first == keys.first || kp.first == "*"
          end
          if matches.count > 0

            child_key_paths = []
            split_matches = matches.map { |match| match.split('.') }

            # universal wildcard
            if matches.index("*") != nil
              child_key_paths = child_key_paths << "*" 
            else
              # normal key-path (including key-pathed wildcard)
              child_key_paths = child_key_paths + split_matches.map { |split_match| split_match.drop(1).join('.') }
            end

            # if there are no more key paths, we just take everything (whitelisted by default)
            new_k = keys.first
            new_v = filter_key_paths(v, child_key_paths, custom_block)
            next if !custom_block.nil? && !custom_block.call(new_k, new_v)
            new_hash[new_k] = new_v 
          end
        end
        return new_hash
      end

      # object?
      return object
    end

    private

    # filters each element
    def self.filter_array(array, key_paths, custom_block=nil)
      new_array = Array.new
      keys = Set.new(key_paths)
      array.each do |i|
        new_array << filter_key_paths(i, key_paths, custom_block)
      end
      return new_array
    end
  end
end