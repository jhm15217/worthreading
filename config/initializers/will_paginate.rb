# config/initializers/will_paginate_array.rb
require 'will_paginate/collection'
Array.class_eval do
  attr_reader :total_pages

  def paginate(options = {})
    raise ArgumentError, "parameter hash expected (got #{options.inspect})" unless Hash === options

    WillPaginate::Collection.create(
      options[:page] || 1,
      options[:per_page] || 15,
      options[:total_entries] || self.length ) do |pager|
        pager.replace self[pager.offset, pager.per_page].to_a
        @total_pages = pager.total_entries / pager.per_page
    end
  end
  
end

# Now you can paginate any array, something like
# @posts = <method that return an array>.paginate( page: params[:page] per_page: 5 )
