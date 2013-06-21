require 'spec_helper'

module Diplomacy
  describe StateParser do
    context "the French starting position" do
      before :each do
        @sp = StateParser.new
        blob = "France:APar,FBre,AMar,Gas,Pic,Bur"
        @gamestate = @sp.parse_state blob
      end

      it "sets France as the owner of all French lands" do

        @gamestate[:Par].owner.should eq("France")
        @gamestate[:Bre].owner.should eq("France")
        @gamestate[:Mar].owner.should eq("France")
        @gamestate[:Gas].owner.should eq("France")
        @gamestate[:Pic].owner.should eq("France")
        @gamestate[:Bur].owner.should eq("France")
      end

      it "creates the correct units" do
        @gamestate[:Par].unit.should_not be_nil
        @gamestate[:Par].unit.nationality.should eq("France")
        @gamestate[:Par].unit.type.should eq(Unit::ARMY)

        @gamestate[:Bre].unit.should_not be_nil
        @gamestate[:Bre].unit.nationality.should eq("France")
        @gamestate[:Bre].unit.type.should eq(Unit::FLEET)
        
        @gamestate[:Mar].unit.should_not be_nil
        @gamestate[:Mar].unit.nationality.should eq("France")
        @gamestate[:Mar].unit.type.should eq(Unit::ARMY)
      end
    end

    context "I'm sorry Austria, you are fucked" do
      before :each do
        @sp = StateParser.new
        blob = "Italy:ATyr,AVen,FIon,Apu,Tus,Pie,Rom,Nap Austria:FAlb,ASer,ABud,Boh,Gal,Vie,Tri,Tyr"
        @gamestate = @sp.parse_state blob
      end

      it "creates an Italian army in Tyrolia" do
        @gamestate[:Tyr].unit.should_not be_nil
        @gamestate[:Tyr].unit.nationality.should eq("Italy")
        @gamestate[:Tyr].unit.type.should eq(Unit::ARMY)
      end

      it "sets Austria as the owner of Tyrolia" do
        @gamestate[:Tyr].owner.should eq("Austria")
      end

      it "creates an Austrian Fleet in Albania" do
        @gamestate[:Alb].unit.should_not be_nil
        @gamestate[:Alb].unit.nationality.should eq("Austria")
        @gamestate[:Alb].unit.type.should eq(Unit::FLEET)
      end

      it "doesn't set Austria as the owner of Albania" do
        @gamestate[:Alb].owner.should_not eq("Austria")
      end
    end
  end
end
