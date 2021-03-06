require 'spec_helper'

module ModelCachable
  describe Save do
    before :each do
      ModelCachable.configure do |config|
        config.cache = Redis.new
        config.transport = double('amqp')
        config.dictionary = [{ name: "ModelCachable::Foo", repo: "Buu", amqp_url: "amqp://queue.users", cache_key: "foo" }]
      end
    end

    describe "Save" do
      it "in repo" do
        ModelCachable.configuration.cache = double('cache')
        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)

        foo = ModelCachable::Foo.new({name: "bla"})
        foo.save

        expect(foo).to be_a(ModelCachable::Foo)
      end

      it "in remote POST" do
        ModelCachable.configuration.cache = double('cache')
        ModelCachable.configuration.dictionary[0][:repo] = "Foo"

        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)
        allow( ModelCachable.configuration.transport ).to receive(:post).with("amqp://queue.users/users", {:foo=>{:id=>nil, :name=>"bla"}}).and_return({ 'id': 1, 'name': 'test' })

        ModelCachable::Foo.repo = nil
        foo = ModelCachable::Foo.new({name: "bla"})
        foo.save

        expect( ModelCachable.configuration.transport ).to have_received(:post).with("amqp://queue.users/users", {:foo=>{:id=>nil, :name=>"bla"}})
        expect(foo).to be_a(ModelCachable::Foo)
        expect(foo.id).to be( 1 )
      end

      it "in remote PUT" do
        ModelCachable.configuration.cache = double('cache')
        ModelCachable.configuration.dictionary[0][:repo] = "Foo"

        allow( ModelCachable.configuration.cache ).to receive(:set).and_return(true)
        allow( ModelCachable.configuration.transport ).to receive(:put).with("amqp://queue.users/users/1", {:foo=>{:id=>1, :name=>"ble"} } ).and_return({ 'id': 1, 'name': 'test' })

        ModelCachable::Foo.repo = nil
        foo = ModelCachable::Foo.new({id: 1,name: "ble"})
        foo.save

        expect( ModelCachable.configuration.transport ).to have_received(:put).with("amqp://queue.users/users/#{foo.id}", {:foo=>{:id=>1, :name=>"ble"}})
        expect(foo).to be_a(ModelCachable::Foo)
        expect(foo.id).to be( 1 )
      end
    end

  end
end
