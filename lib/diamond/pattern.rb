#!/usr/bin/env ruby
module Diamond
  
  class Pattern
    
    attr_reader :name
    
    def initialize(name, &proc)
      @name = name
      @proc = proc      
    end
    
    def compute(range, interval)
      @proc.call(range, interval)
    end
    
    def self.all
      ensure_populated
      @patterns
    end
    
    def self.find(name)
      all.find { |p| p.name == name }
    end
    class << self 
      alias_method :[], :find
    end
    
    private
    
    def self.ensure_populated
      @patterns ||= []
      return unless @patterns.empty?
      
      @patterns << Pattern.new("Up") do |r, i| 
        a = []
        0.upto(r) { |n| a << (n * i) }
        a
      end
        
      @patterns << Pattern.new("Down") do |r, i|
        a = []
        r.downto(0) { |n| a << (n * i) }
        a
      end
        
      @patterns << Pattern.new("UpDown") do |r, i|
        a = []
        0.upto(r) { |n| a << (n * i) }
        [(r-1), 0].max.downto(0) { |n| a << (n * i) }
        a
      end
      
      @patterns << Pattern.new("DownUp") do |r, i|
        a = []
        r.downto(0) { |n| a << (n * i) }
        1.upto(r) { |n| a << (n * i) }          
        a
      end
        
    end
    
  end
  
end
