module Diplomacy

  class Unit
    ARMY = 1
    FLEET = 2
    
    attr_accessor :nationality
    attr_accessor :type
    
    def initialize(nationality=nil, type=nil)
      @nationality = nationality
      @type = type
    end

    def is_army?
      type == ARMY
    end

    def is_fleet?
      type == FLEET
    end

    def type_to_s
      return "A" if is_army?
      return "F" if is_fleet?
      return "Unknown"
    end
  end

  class AreaState
    attr_accessor :owner, :unit

    def initialize(owner = nil, unit = nil)
      @owner = owner
      @unit = unit
    end

    def to_s
      out = ""
      out << "#{@owner}"
      out << ", #{@unit.type_to_s} (#{@unit.nationality})" if @unit
      out
    end
  end

  class GameState < Hash
    attr_accessor :retreats
    
    def initialize
      self.default_proc = proc {|this_hash, nonexistent_key| this_hash[nonexistent_key] = AreaState.new }
      self.retreats = {}
    end
    
    def area_state(area)
      if Area === area
        self[area.abbrv] || (self[area.abbrv] = AreaState.new)
      elsif Symbol === area
        self[area] || (self[area] = AreaState.new)
      end
    end
    
    def area_unit(area)
      area_state(area).unit
    end
    
    def set_area_unit(area, unit)
      area_state(area).unit = unit
    end
    
    def apply_orders!(orders, adjust=false)
      orders.each do |order|
        if Move === order && order.succeeded?
          if (dislodged_unit = area_unit(order.dst))
            @retreats[order.dst] = area_unit(order.dst)
          end
          
          set_area_unit(order.dst, area_unit(order.unit_area))
          set_area_unit(order.unit_area, nil)
          
          self[order.dst].owner = order.unit.nationality if adjust
        end
      end
    end

    def apply_retreats!(retreats, adjust=false)
      retreats.each do |r|
        set_area_unit(r.dst, self.retreats[r.unit_area]) if r.succeeded?
        # do nothing about the failed ones, they will be discarded

        self[r.dst].owner = r.unit.nationality if adjust
      end
    end

    def apply_builds!(builds)
      builds.each do |b|
        set_area_unit(b.unit_area, b.build ? b.unit : nil) if b.succeeded?
      end
    end
  end
end
