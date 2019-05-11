module AdminHelper
  def is_admin?
    redirect_to root_path, notice: 'Unauthorized' unless current_user.admin
  end
end
