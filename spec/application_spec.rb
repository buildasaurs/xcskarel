require 'xcskarel/application'

class Opts
  attr_accessor :no_pretty
  attr_accessor :no_filter
end

describe XCSKarel do
  describe XCSKarel::Application do
    describe "format" do

      def default_options
        opts = Opts.new
        opts.no_filter = false
        opts.no_pretty = false
        return opts
      end

      it "filters correctly empty leaf arrays" do
        object = [{
          "errors" => {
            "unresolvedIssues" => [],
            "resolvedIssues" => []
          },
          "testFailures" => {
            "unresolvedIssues" => ["one"],
            "resolvedIssues" => []
          }
        }]
        exp = JSON.pretty_generate([{
            "testFailures" => {
              "unresolvedIssues" => ["one"]
            }
        }])
        expect(XCSKarel::Application.format(object, default_options, ["errors.*", "testFailures.*"], false)).to eq(exp)
      end
    end
  end
end