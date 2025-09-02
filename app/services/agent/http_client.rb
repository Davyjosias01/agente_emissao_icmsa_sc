#frozen_string_literal: true
require 'rest-client'
require 'json'

  class HttpClient
    def initialize(base_url:, token:)      
      @base_url = base_url
      @token    = token
    end

    def getServices(path, query_params = {})
      response = RestClient.get(
        url_for(path), 
        {
          params: query_params,
          Authorization: @token,
          Accept: :json
        }
      )
      JSON.parse(response.body)
    end


    private

    def url_for(path)
      return path if path.start_with?("http://", "https://")
      "#{@base_url}/#{path.sub(%r{\A/+}, "")}"
    end
  end


if __FILE__ == $0
  require 'dotenv/load'


  base_url = ENV["INTEGRATION_BASE_URL"]
  token    = ENV["INTEGRATION_TOKEN"]


  if base_url.to_s.empty? || token.to_s.empty?
    abort "Faltam variáveis no .env: INTEGRATION_BASE_URL e/ou INTEGRATION_TOKEN"
  end


  client = HttpClient.new(base_url: ENV["INTEGRATION_BASE_URL"], token: ENV["INTEGRATION_TOKEN"])
  res = client.getServices(
    ENV["POOL_PATH"], 
    {
      obligation: "selecao_empresas_importacao_nota_fiscal",
      date_start: "01/08/2025",
      date_end: "01/09/2025",
      fields: "cnpj,dominio_code,fantasy_name,phone,email"
    }
  )

  puts res
end