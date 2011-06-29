require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

def should_print method
  describe method do
    it "should print a message" do
      $stdout.should_receive(:print).with(/a special message/)
      Inform.send(method, "a special message")
    end
    it "should interpolate keyword arguments" do
      $stdout.should_receive(:print).with(/hello.+hey.+you.+goodbye/)
      Inform.send(method, "hello %{a} %{b} goodbye", :a => 'hey', :b => 'you')
    end
  end
end

def should_not_print method
  describe method do
    it "should not print a message" do
      $stdout.should_not_receive(:print)
      Inform.send(method, "a special message")
    end
  end
end

def should_accept_block method
  describe ":#{method.to_s} with a block" do
    it "should print out the task being executed" do
      $stdout.should_receive(:print).with(/message/)
      Inform.send(method, "message") { true }
    end
    it "should print Done once the task is complete" do
      $stdout.should_receive(:print).with(/Done/)
      Inform.send(method, "") { true }
    end
    it "should evaluate the passed block and return the result" do
      Inform.send(method, "") { 'hello' }.should == 'hello'
    end
    it "should allow us to print messages from within a block" do
      $stdout.should_receive(:print).with(/open/)
      $stdout.should_receive(:print).with(/inner/)
      Inform.send(method, "open") { Inform.send(method, "inner") }
    end
  end
end

describe Inform do
  before :each do
    @oldlevel = Inform.level
    $stdout.stub(:print => nil) # SSSSSH.
  end
  after :each do
    Inform.level = @oldlevel
  end

  describe :level= do
    it "should set the log level" do
      Inform.level = :info
      Inform.level.should == :info
    end
    
    it "should not allow us to set a log level that isn't recognized" do
      lambda {Inform.level = :warble}.should raise_error /unrecognized/i
    end
  end
  
  context "with log level debug" do
    before { Inform.level = :debug }

    should_print :debug    
    should_print :info    
    should_accept_block :info
    # should_accept_block :debug

    should_print :warning
    should_print :error
  end
  
  context "with log level set to :info" do
    before { Inform.level = :info }
    should_not_print :debug
    should_print :info
    should_accept_block :info
    # should_accept_block :debug
    
    should_print :warning
    should_print :error
  end
  
  context "with log level set to :warning" do
    before { Inform.level = :warning }
    should_not_print :debug
    should_not_print :info
    should_print :warning
    should_print :error
  end

  context "with log level set to :error " do
    before { Inform.level = :error }
    should_not_print :debug
    should_not_print :info
    should_not_print :warning
    should_print :error
    
    describe :info do
      it "should still execute the code block" do
        Inform.info("") { 'hello' }.should == 'hello'
      end
    end
  end
end