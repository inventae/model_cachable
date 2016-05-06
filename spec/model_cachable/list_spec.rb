require 'spec_helper'

module ModelCachable
  describe "List" do
    before :each do
      ModelCachable.configure do |config|
        config.cache = Redis.new
        config.transport = double('amqp')
        config.dictionary = [{ name: "ModelCachable::Foo", repo: "Buu", amqp_url: "amqp://queue.users/users", cache_key: "foo" }]
      end
    end

    describe "#find" do
      it "find test" do
        ModelCachable::Foo.repo.find(:all)
      end
    end

  end
end
