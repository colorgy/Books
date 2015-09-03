ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel 'Recent Bills' do
          table do
            thead do
              tr do
                %w(id user amount state paid_at created_at).each(&method(:th))
              end
            end

            tbody do
              Bill.order('id desc').first(20).map do |bill|
                tr do
                  td bill.id
                  td { a bill.user.name, href: admin_user_path(bill.user) }
                  td bill.amount
                  td do
                    tag = nil
                    case bill.state
                    when "paid"
                      tag = :ok
                    when "payment_pending"
                      tag = :warning
                    end
                    tag.nil? ? status_tag(bill.state) : status_tag(bill.state, tag)
                  end
                  td bill.paid_at
                  td bill.created_at
                end
              end
            end
          end
        end
      end

      column do
        panel 'Recent Order' do
          table do
            thead do
              tr do
                %w(id user amount state created_at).each(&method(:th))
              end
            end

            tbody do
              Order.order('id desc').first(20).map do |order|
                tr do
                  td order.id
                  td { a order.user.name, href: admin_user_path(order.user) }
                  td order.price
                  td do
                    tag = nil
                    case order.state
                    when "paid"
                      tag = :ok
                    when "new"
                      tag = :warning
                    when "payment_pending"
                      tag = :warning
                    end
                    tag.nil? ? status_tag(order.state) : status_tag(order.state, tag)
                  end
                  td order.created_at
                end
              end
            end
          end
        end
      end
    end

  end # content
end
