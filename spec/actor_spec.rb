require File.dirname(__FILE__) + '/spec_helper'
require 'nanite'
require 'nanite/mapper'
require 'nanite/actor'

class WebDocumentImporter < Nanite::Actor
  expose :import, :cancel
  
  def import
    1
  end
  def cancel
    0
  end
end

module Actors
  class ComedyActor < Nanite::Actor
    expose :fun_tricks
    def fun_tricks
      :rabbit_in_the_hat
    end
  end
end

describe Nanite::Actor do
  describe ".default_prefix" do
    it "is calculated as default prefix as const path of class name" do
      Nanite::Actor.default_prefix.should       == "nanite/actor"
      Actors::ComedyActor.default_prefix.should == "actors/comedy_actor"
      WebDocumentImporter.default_prefix.should == "web_document_importer"    
    end    
  end
  
  describe ".provides_for(prefix)" do
    before :each do
      @provides = Actors::ComedyActor.provides_for("money")
    end
    it "returns an array" do
      @provides.should be_kind_of(Array)
    end

    it "maps exposed service methods to prefix" do
      @provides.should == ["/money/fun_tricks"]
      wdi_provides = WebDocumentImporter.provides_for("webfiles")
      wdi_provides.should include("/webfiles/import")
      wdi_provides.should include("/webfiles/cancel")
    end
  end
end