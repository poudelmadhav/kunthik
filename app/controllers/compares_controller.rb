class ComparesController < ApplicationController
  def index
    @item1 = Item.find(params['item1'])
    @item2 = Item.find(params['item2'])
  end
end
