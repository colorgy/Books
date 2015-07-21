class GroupSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :code, :leader_id, :leader_name, :leader_avatar_url, :course_ucode, :course_name, :course_lecturer_name, :book_id, :book_name, :book_price, :book_image_url, :created_at, :updated_at, :shipped_at, :received_at, :organization_code, :state, :deadline, :orders_count, :unpaid_orders_count, :supplier_code
end
