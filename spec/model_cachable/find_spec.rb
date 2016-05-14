require 'spec_helper'

module ModelCachable
  describe Find do
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
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)

        FactoryGirl.create(:buu, id: 1)
        foo = ModelCachable::Foo.find(1)
        expect( foo.id ).to eq( 1 )
      end

      it "in redis" do
        ModelCachable.configuration.cache = double('cache')
        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return({ 'id': 1, 'name': 'test' }.to_json)

        foo = ModelCachable::Foo.find(1)

        expect( ModelCachable.configuration.cache ).to have_received(:get).with("foo:1")
        expect( foo.id ).to eq( 1 )
      end

      it "in amqp" do
        ModelCachable.configuration.cache = double('cache')
        ModelCachable.configuration.dictionary[0][:repo] = "Foo"

        allow( ModelCachable.configuration.cache ).to receive(:get).with("foo:1").and_return(nil)
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)
        allow( ModelCachable.configuration.transport ).to receive(:get).with("amqp://queue.users/users/1").and_return({ 'id': 1, 'name': 'test' })

        ModelCachable::Foo.repo = nil
        foo = ModelCachable::Foo.find(1)

        expect( ModelCachable.configuration.transport ).to have_received(:get).with("amqp://queue.users/users/1")
        expect( foo.id ).to eq( 1 )
      end
    end

  end
end
