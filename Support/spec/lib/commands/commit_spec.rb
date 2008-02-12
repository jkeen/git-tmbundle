require File.dirname(__FILE__) + '/../../spec_helper'

describe SCM::Git::Commit do
  before(:each) do
    @commit = SCM::Git::Commit.new
  end
  include SpecHelpers
  
  it "should parse a commit" do
    @commit.command_output << <<-EOF
Created commit ff4ba93: some message
 1 files changed, 2 insertions(+), 0 deletions(-)
Unrecognized line
EOF
    # @commit.should_receive(:command).and_return(commit_output)

    result = @commit.commit("some message")
    result[:rev].should == "ff4ba93"
    result[:message].should == "some message"
    result[:insertions].should == 2
    result[:deletions].should == 0
    result[:files_changed].should == 1
    result[:output].should == "Unrecognized line\n"
  end
end