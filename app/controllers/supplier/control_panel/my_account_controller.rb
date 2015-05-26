class Supplier::ControlPanel::MyAccountController < Supplier::ControlPanelController
  def show
    redirect_to edit_supplier_control_panel_my_account_path
  end

  def edit
    @supplier_staff = current_supplier_staff
  end

  def update
    @supplier_staff = current_supplier_staff
    respond_to do |format|
      if @supplier_staff.update(supplier_staff_params)
        format.html { redirect_to supplier_control_panel_my_account_path, notice: '資料更新成功！' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def supplier_staff_params
    p = params.require(:supplier_staff).permit(:username, :email, :name, :password, :password_confirmation)
    p.delete(:password) if p[:password].blank?
    p.delete(:password_confirmation) if p[:password_confirmation].blank?
    p
  end
end
