require "spec_helper"

describe Permalink::Orm::Mongoid do
  before { pending }

  let(:model) { Article }
  it_should_behave_like "orm"

  it "should override to_param method" do
    model.permalink :title

    record = model.create(:title => "Some nice post")
    record.to_param.should == "some-nice-post"
  end
end