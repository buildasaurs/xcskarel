require 'xcskarel/filter'

describe XCSKarel do
  describe XCSKarel::Filter do

    def test(inObj, key_paths, custom_block=nil)
      XCSKarel::Filter.filter_key_paths(inObj, key_paths, custom_block)
    end

    it "handles empty hash" do
      expect(test({}, [])).to eq({})
    end

    it "handles empty array" do
      expect(test([], [])).to eq([])
    end

    it "handles flat array of strings" do
      expect(test(["apples", "oranges"], [])).to eq(["apples", "oranges"])
    end

    it "filters out everything from a simple hash" do
      expect(test({"apples" => "green", "oranges" => "orange"}, [])).to eq({})
    end

    it "lets through only selected keys is a simple hash" do
      expect(test({"apples" => "green", "oranges" => "orange"}, ["oranges"])).to eq({"oranges" => "orange"})
    end

    it "handles basic key path with a hash" do
      obj = {
        "apples" => "green",
        "oranges" => {
          "new" => 2,
          "old" => -2
        }
      }
      exp = {
        "oranges" => {
          "old" => -2
        }
      }
      expect(test(obj, ["oranges.old"])).to eq(exp)
    end

    it "keeps full values when hashes and key is already whitelisted" do
      obj = {
        "apples" => "green",
        "blackberries" => 12,
        "oranges" => {
          "new" => 2,
          "old" => -2
        }
      }
      exp = {
        "apples" => "green",
        "oranges" => {
          "new" => 2,
          "old" => -2
        }
      }
      expect(test(obj, ["oranges.*", "apples"])).to eq(exp)
    end

    it "handles basic key path with an array without popping the key path" do
      obj = [
        "apples",
        {
          "new" => 2,
          "old" => -2
        }
      ]
      exp = [
        "apples",
        {
          "new" => 2
        }
      ]
      expect(test(obj, ["new"])).to eq(exp)
    end

    it "custom block can override and filter out based on keys" do
      obj = [
        "apples",
        {
          "new" => ["one", "two"],
          "old" => []
        }
      ]
      exp = [
        "apples",
        {
          "new" => ["one", "two"]
        }
      ]
      custom_block = lambda do |k,v|
        return true unless v.is_a?(Array)
        return v.count > 0
      end
      expect(test(obj, ["new", "old"], custom_block)).to eq(exp)
    end

    it "handles the wildcard symbol in the middle of a keypath" do
      obj = {
        "errors" => {
          "status" => 0,
          "data" => "1234abcd"
        },
        "warnings" => {
          "status" => 1,
          "data" => "abcd1234"
        }
      }
      exp = {
        "errors" => {
          "status" => 0
        },
        "warnings" => {
          "status" => 1
        }
      }
      expect(test(obj, ["*.status"])).to eq(exp)
    end
  end
end