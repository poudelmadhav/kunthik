class HomeController < ApplicationController
  def index
    @items = Item.all
  end

  def terms
  end

  def privacy
  end
end
