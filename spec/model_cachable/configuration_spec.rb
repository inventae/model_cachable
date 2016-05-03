require 'spec_helper'

module ModelCachable
  describe Configuration do
    after :each do
      ModelCachable.configuration = nil
    end

    describe "#configuration" do
      it "allows configuration by options block" do
        x = nil
        ModelCachable.configure do |config|
          x = config
        end
        expect(x).to_not be_nil
      end

      it "allows repository definition" do
        repo = double('repository')
        ModelCachable.configure do |config|
          config.repository = repo
        end
        expect(ModelCachable.configuration.repository).to eq(repo)
      end

      it "allows repository definition" do
        repo = double('repository')
        ModelCachable.configure do |config|
          config.repository = repo
        end
        expect(ModelCachable.configuration.repository).to eq(repo)
      end

      it "allows cache definition" do
        repo = double('cache')
        ModelCachable.configure do |config|
          config.cache = repo
        end
        expect(ModelCachable.configuration.cache).to eq(repo)
      end

      it "allows dictionary definition" do
        repo = double('dictionary')
        ModelCachable.configure do |config|
          config.dictionary = repo
        end
        expect(ModelCachable.configuration.dictionary).to eq(repo)
      end
    end

    describe "#get_klass" do
      it "translate dictionary to klass" do
        class ModelCachable::Foo; end

        dictionary = []
        dictionary << { name: "ModelCachable::Foo", repo: "Buu", cache_key: "foo" }

        ModelCachable.configure do |config|
          config.dictionary = dictionary
        end

        klass = ModelCachable.configuration.get_klass( ModelCachable::Foo )
        expect( klass.new ).to be_a_kind_of( Buu )
      end
    end

  end
end
