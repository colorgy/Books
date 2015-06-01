# = Helper To Make Resource APIs Paginatable
#
# Paginating the requested items can avoid returning too much information
# in a single response. API callers can iterate over the results using
# pagination instead of rerteving all the data in one time, ruining the
# database connection or network.
#
# There are two parameters clients can use: +per_page+ and +page+. The former
# is used for setting how many data will be returned in each page, there will
# be a maxium limit and default value for each API:
#
#   GET /posts?per_page=10
#
# <em>The server will respond 10 items at a time.</em>
#
# Use the +page+ parameter to specify which to retrieve:
#
#   GET /posts?page=5
#
# Pagination info will be provided in the HTTP Link header like this:
#
#   Link: <http://api-server.dev/movies?page=1>; rel="first",
#         <http://api-server.dev/movies?page=4>; rel="prev"
#         <http://api-server.dev/movies?page=6>; rel="next",
#         <http://api-server.dev/movies?page=238>; rel="last"
#
# <em>Line breaks are added for readability.</em>
#
# Which follows the proposed RFC 5988 standard.
#
# == Usage
#
# Include this +Concern+ in your Grape API class:
#
#   class SampleAPI < Grape::API
#     include APIHelpers::Paginatable
#   end
#
# then set the options for pagination in the grape method:
#
#   resources :posts do
#     get do
#       pagination User.count, default_per_page: 25, maxium_per_page: 100
#
#       # ...
#     end
#   end
#
# Then use the helper methods, like this:
#
#   User.page(page).per(per_page)
#
# HTTP Link header will be automatically set.
module APIHelpers::Paginatable
  extend ActiveSupport::Concern

  def pagination(items_count, default_per_page: 20, maxium_per_page: 100, set_link_header: true)
    items_count = items_count.count if items_count.respond_to? :count

    @per_page = (params[:per_page] || default_per_page).to_i
    @per_page = maxium_per_page if @per_page > maxium_per_page
    @per_page = 1 if @per_page < 1

    items_count = 1 if items_count < 1
    pages_count = (items_count.to_f / @per_page).ceil
    pages_count = 1 if pages_count < 1

    @page = (params[:page] || 1).to_i
    @page = pages_count if @page > pages_count
    @page = 1 if @page < 1

    link_headers ||= []

    if current_page < pages_count
      link_headers << "<#{add_or_replace_uri_param(request.url, :page, current_page + 1)}>; rel=\"next\""
      link_headers << "<#{add_or_replace_uri_param(request.url, :page, pages_count)}>; rel=\"last\""
    end
    if current_page > 1
      link_headers << "<#{add_or_replace_uri_param(request.url, :page, (current_page > pages_count ? pages_count : current_page - 1))}>; rel=\"prev\""
      link_headers << "<#{add_or_replace_uri_param(request.url, :page, 1)}>; rel=\"first\""
    end

    link_header = link_headers.join(', ')

    if set_link_header
      self.header('Link', link_header) if self.respond_to?(:header)
      response.headers['Link'] = link_header if defined?(response) && response.respond_to?(:headers)
    end

    link_header
  end

  # Getter for the current page
  def page
    @page
  end

  alias_method :current_page, :page

  # Getter for per_page
  def per_page
    @per_page
  end

  alias_method :page_with, :per_page

  def add_or_replace_uri_param(url, param_name, param_value)
    uri = URI(url)
    params = URI.decode_www_form(uri.query || '')
    params.delete_if { |param| param[0].to_s == param_name.to_s }
    params << [param_name, param_value]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  # Return the 'per_page' param description
  def self.per_page_param_desc
    "Specify how many items you want each page to return."
  end

  # Return the 'page' param description
  def self.page_param_desc
    "Specify which page you want to get."
  end
end
