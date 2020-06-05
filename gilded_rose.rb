require 'delegate'

AGED_BRIE      = 'Aged Brie'
BACKSTAGE_PASS = 'Backstage passes to a TAFKAL80ETC concert'
CONJURED       = 'Conjured'
SULFURAS       = 'Sulfuras, Hand of Ragnaros'

class ItemUpdater < SimpleDelegator
  def quality=(quality)
    super(quality.clamp(0, 50))
  end

  def call
    age
    if name != SULFURAS
      self.quality += value_change
    end
  end

private

  def expired?
    sell_in.negative?
  end

  def age
    if name != SULFURAS
      self.sell_in -= 1
    end
  end

  def value_change
    if name == AGED_BRIE
      expired? ? 2 : 1
    elsif name == BACKSTAGE_PASS
      if expired?
        -quality
      elsif sell_in < 5
        3
      elsif sell_in < 10
        2
      else
        1
      end
    elsif name.start_with?(CONJURED)
      expired? ? -4 : -2
    else
      expired? ? -2 : -1
    end
  end
end

def update_quality(items)
  items.each do |item|
    ItemUpdater.new(item).call
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

