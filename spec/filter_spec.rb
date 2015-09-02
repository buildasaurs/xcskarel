require 'xcskarel/filter'

describe XCSKarel do
  describe XCSKarel::Filter do

    def test(inObj, key_paths)
      XCSKarel::Filter.filter_key_paths(inObj, key_paths)
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
      expect(test(obj, ["oranges", "apples"])).to eq(exp)
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
  end
end