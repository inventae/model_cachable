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
      it "in repo" do
        ModelCachable.configuration.cache = double('cache')
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:2").and_return({ 'id': 2, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:a6e0da24541e45b0f7e6305e63663da61709b6a5").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)

        FactoryGirl.create_list(:buu, 2)
        foos = ModelCachable::Foo.all

        expect( foos.length ).to eq( 2 )
      end

      it "in redis" do
        ModelCachable.configuration.cache = double('cache')
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:2").and_return({ 'id': 2, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:a6e0da24541e45b0f7e6305e63663da61709b6a5").and_return([1,2].to_json)

        foos = ModelCachable::Foo.all

        expect( ModelCachable.configuration.cache ).to have_received(:get).with("foo:query:a6e0da24541e45b0f7e6305e63663da61709b6a5")
        expect( foos.length ).to eq( 2 )
      end

      it "in amqp" do
        ModelCachable.configuration.cache = double('cache')
        ModelCachable.configuration.dictionary[0][:repo] = "Foo"

        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:2").and_return({ 'id': 2, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:a6e0da24541e45b0f7e6305e63663da61709b6a5").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)
        allow( ModelCachable.configuration.transport ).to receive(:get).with("amqp://queue.users/users", { query: {}}).and_return([1,2])

        ModelCachable::Foo.repo = nil
        foos = ModelCachable::Foo.all

        expect( ModelCachable.configuration.transport ).to have_received(:get).with("amqp://queue.users/users", { query: {} })
        expect( foos.length ).to eq( 2 )
      end
    end

  end
end
