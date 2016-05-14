require 'spec_helper'

module ModelCachable
  describe "Where" do
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
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:427cbfe5b6c01dcba65ef394d79ec0364e8b487c").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)

        buus = [FactoryGirl.create(:buu, id: 1), FactoryGirl.create(:buu, id: 2)]

        foos = ModelCachable::Foo.unscoped.where(id_eq: buus.first.id).all
        expect( foos.length ).to eq( 1 )
      end

      it "in redis" do
        ModelCachable.configuration.cache = double('cache')
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:2").and_return({ 'id': 2, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:b1b28b8330112a2361e799d4fe95bdaae03e6a3f").and_return([1,2].to_json)

        foos = ModelCachable::Foo.unscoped.where(name_eq: "test").all

        expect( ModelCachable.configuration.cache ).to have_received(:get).with("foo:query:b1b28b8330112a2361e799d4fe95bdaae03e6a3f")
        expect( foos.length ).to eq( 2 )
      end

      it "in amqp" do
        ModelCachable.configuration.cache = double('cache')
        ModelCachable.configuration.dictionary[0][:repo] = "Foo"

        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:query:b1b28b8330112a2361e799d4fe95bdaae03e6a3f").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)
        allow( ModelCachable.configuration.transport ).to receive(:get).with("amqp://queue.users/users", { query: {q: {name_eq: "test"}}}).and_return([1])

        ModelCachable::Foo.repo = nil
        foos = ModelCachable::Foo.unscoped.where(name_eq: "test").all

        expect( ModelCachable.configuration.transport ).to have_received(:get).with("amqp://queue.users/users", { query: {q: {name_eq: "test"}}})
        expect( foos.first.id ).to eq( 1 )
      end

    end

  end
end
