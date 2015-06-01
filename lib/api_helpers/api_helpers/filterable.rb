# = Helper To Make Resource APIs Filterable
#
# A filterable resource API supports requests to filter resources according to
# specific criteria, using the +filter+ query parameter.
#
# For example, the following is a request for all products that has a
# particular color:
#
#   GET /products?filter[color]=red
#
# With this approach, multiple filters can be applied to a single request:
#
#   GET /products?filter[color]=red&filter[status]=in-stock
#
# <em>Multiple filters are applied with the AND condition.</em>
#
# OR conditions of a single value can be represented as:
#
#   GET /products?filter[color]=red,blue,yellow
#
# A few functions: +not+, +greater_then+, +less_then+, +greater_then_or_equal+,
# +less_then_or_equal+, +between+ and +like+ can be used while filtering
# the data, for example:
#
#   GET /products?filter[color]=not(red)
#   GET /products?filter[price]=greater_then(1000)
#   GET /products?filter[price]=less_then_or_equal(2000)
#   GET /products?filter[price]=between(1000,2000)
#   GET /products?filter[name]=like(%lovely%)
#
# == Usage
#
# Include this +Concern+ in your Grape API class:
#
#   class SampleAPI < Grape::API
#     include APIHelpers::Filterable
#   end
#
# then use the +filter+ method like this:
#
#   resources :products do
#     get do
#       @products = filter(Post, filterable_fields: [:name, :price, :color])
#       # ...
#     end
#   end
#
# <em>The +filter+ method will return the scoped model, based directly
# from the requested URL. Further usage of this method can be
# found in the {docs of the
# +HelperMethods+ class}[rdoc-ref:APIHelpers::Filterable::HelperMethods].
# </em>
module APIHelpers::Filterable
  extend ActiveSupport::Concern

  # Filter resources of a collection from the request parameter
  #
  # Params:
  #
  # +resource+::
  #   +ActiveRecord::Base+ or +ActiveRecord::Relation+ resource collection
  #   to filter data from
  #
  # +filterable_fields+::
  #   +Array+ of +Symbol+s fields that are allowed to be filtered, default
  #   to all
  def filter(resource, filterable_fields: [])
    # parse the request parameter
    if params[:filter].is_a? Hash
      @filter = params[:filter]
      filterable_fields = filterable_fields.map(&:to_s)

      @filter.each_pair do |field, condition|
        next if filterable_fields.present? && !filterable_fields.include?(field)
        field = resource.connection.quote_string(field)

        next if resource.columns_hash[field].blank?
        field_type = resource.columns_hash[field].type

        # if a function is used
        if func = condition.match(/(?<function>[^\(\)]+)\((?<param>.+)\)/)
          case func[:function]
          when 'not'
            values = func[:param].split(',')
            values.map!(&:to_bool) if field_type == :boolean
            resource = resource.where.not(field => values)
          when 'greater_then'
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" > ?", func[:param])
          when 'less_then'
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" < ?", func[:param])
          when 'greater_then_or_equal'
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" >= ?", func[:param])
          when 'less_then_or_equal'
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" <= ?", func[:param])
          when 'between'
            param = func[:param].split(',')
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" BETWEEN ? AND ?", param.first, param.last)
          when 'like'
            resource = resource.where("\"#{resource.table_name}\".\"#{field}\" LIKE ?", func[:param])
          end
        # if not function
        else
          values = condition.split(',')
          values.map!(&:to_bool) if field_type == :boolean
          resource = resource.where(field => values)
        end
      end
    end

    return resource
  end

  # Return the 'fields' param description
  def self.filter_param_desc(for_field: nil)
    if for_field.present?
      "Filter data base on the '#{for_field}' field."
    else
      "Filter the data."
    end
  end
end
