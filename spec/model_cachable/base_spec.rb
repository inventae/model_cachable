require 'spec_helper'

module ModelCachable
  describe Base do
    before :all do
      ModelCachable.configure do |config|
        config.dictionary = [{ name: "ModelCachable::Foo", repo: "Buu", cache_key: "foo" }]
      end
    end

    let(:foo){ ModelCachable::Foo.new }

    describe "#get_object" do
      it "get class repo from object class" do
        klass = foo.repo
        expect( klass.new ).to be_a_kind_of( Buu )
      end
    end

  end
end
