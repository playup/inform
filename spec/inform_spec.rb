require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

def should_print method
  describe method do
    it "should print a message" do
      Inform.should_receive(:say).with(/a special message/)
      Inform.send(method, "a special message")
    end
  end
end

def should_not_print method
  describe method do
    it "should not print a message" do
      Inform.should_not_receive(:say)
      Inform.should_not_receive(:print)
      Inform.send(method, "a special message")
    end
  end
end
  
# TODO: refactor, deal with all combinations of message / log level
describe Inform do
  before :each do
    @oldlevel = Inform.level
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
    before :each do
      Inform.level = :debug
      Inform.stub(:say => nil) # SSSSSH.
    end

    should_print :debug    
    should_print :info    

    describe ":info with a block" do
      it "should print out the task being executed" do
        Inform.should_receive(:say).with(/message/)
        Inform.info("message") { true }
      end
      it "should print Done once the task is complete" do
        Inform.should_receive(:say).with(/Done/)
        Inform.info("") { true }
      end
      it "should evaluate the passed block and return the result" do
        Inform.info("") { 'hello' }.should == 'hello'
      end
      it "should allow us to print messages from within a block" do
        Inform.should_receive(:say).with(/open/)
        Inform.should_receive(:say).with(/inner/)
        Inform.info("open") { Inform.debug("inner") }
      end
    end

    should_print :warning
    should_print :error
  end
  
  context "with log level set to :info" do
    before { Inform.level = :info }
    should_not_print :debug
    should_print :info
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

describe String do
  describe :% do
    it {
      (
        "%{greeting} there %{name}.  How are you today %{name}?" % { :name => 'Ash', :greeting => 'Hi' }
      ).should == "Hi there Ash.  How are you today Ash?"
    }
  end
end
