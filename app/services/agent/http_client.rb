#frozen_string_literal: true

module Agent 
  class HttpClient
    Response = Struct.new(:status, :body, :headers)
      def success? = (200..299).include?(status.to_i)
    end


    def initialize(base_url:, token:)
      require "http"
      @base_url = base_url.chomp("/")
      @client = HTTP
        .use(:auto_inflate)
        .timeout(connect: 5, read: 20, write: 20)
        .headers("Authorization" => token, "Content-Type" => "application/json")
      @persistent = @client.persistent(@base_url)
    end


    def get(path, params = {})
      res = @persistent.get(url_for(path), params: params)
      Response.new(res.status.to_i, res.body.to_s, res.headers.to_h)
    rescue => e
      Response.new(599, "HTTP GET error: #{e.class}: #{e.message}", {})
    end


    def post(path, body, headers={})
      res = @persistent.headers(headers).post(url_for(path), body: body)
      Response.new(res.status.to_i, res.body.to_s, res.headers.to_h)
    rescue => e
      Response.new(599, "HTTP POST error: #{e.class}: #{e.message}", {})
    end


    def close
      @persistent.close if @persistent&.respond_to?(:close)
    end

    
    private

    def url_for(path)
      return path if path.start_with?("http://" || "https://")
      "#{@base_url}/#{path.sub(%r{\A/+}, "")}"
    end
  end
end