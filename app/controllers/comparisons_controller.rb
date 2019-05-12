class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comparison = Comparison.create!(comparison_params)
    # binding.pry
    if @comparison.item1.present?
      Item.find(@comparison.item1).update_score
      redirect_to item_path(@comparison.item1), notice: 'Item rated successfully.'
    elsif @comparison.item2.present?
      Item.find(@comparison.item2).update_score
      redirect_to item_path(@comparison.item2), notice: 'Item rated successfully.'
    else
      redirect_to root_path, notice: 'Error.'
    end
  end

  private

  def comparison_params
    params.require(:comparison).permit(:reason, :item1, :item2)
  end
end