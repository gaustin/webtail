require 'net/http'
#require 'webtail/formats'

module WebTail::Poller
    attr_accessor :query, :latest_results, :initial_url, :refresh_url

    def initialize(query, initial_url, opts = nil)
      @query = query
      @initial_url = initial_url
      @refresh_url = opts[:refresh_url] || @initial_url unless opts.nil?
    end

    def refresh
      unless @latest_results
        @latest_results = initial_data
      else
        @latest_results = refresh_data
      end
      @refresh_url ||= @refresh_url || @initial_url
    end

    def render_latest_results(formatter = nil, &block)
      format_block = block unless block.nil?
      @latest_results.inject("") do |output, item|
        if formatter.nil? && block.nil?
          output += format(item)
        elsif formatter.nil?
          output += block.call(item)
        else
          output += formatter.format(item)
        end
      end
    end
    
    def format(item)
      item.to_s
    end

    protected
    def initial_data
      Net::HTTP.get(URI.parse(@initial_url % @query))
    end

    def refresh_data
      Net::HTTP.get(URI.parse(@refresh_url % @query))
    end
end