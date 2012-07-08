module WebServiceClient
  class WebServiceFacade
    require 'net/http'

    @@token_moip = "ZY8LQJPHOIDWQSSJZBE3SZD73TNNEEVZ"
    @@chave_moip = "ZBT6AW04HEYGIXZFCA7RKO28EFFI8G8MJEFKJOJC"
    @@url_moip_instrucao_unica = "https://desenvolvedor.moip.com.br/sandbox/ws/alpha/EnviarInstrucao/Unica"
    @@url_moip_cancelar_pagamento = "https://desenvolvedor.moip.com.br/sandbox/ws/alpha/CancelarPagamento"
    @@url_moip_autorizar_pagamento = "https://desenvolvedor.moip.com.br/sandbox/ws/alpha/AutorizarPagamento"
    @@url_moip_consultar_instrucao = "https://desenvolvedor.moip.com.br/sandbox/ws/alpha/ConsultarInstrucao"
    
    def self.chamada_moip tipo, dado
      case tipo
      when :instrucao_unica
        uri = URI.parse(@@url_moip_instrucao_unica)
        request = Net::HTTP::Post.new(uri.path)
        request.body = dado
      when :cancelar_pagamento
        uri = URI.parse(@@url_moip_cancelar_pagamento)
        request = Net::HTTP::Put.new(uri.path)
        request.body = dado
      when :autorizar_pagamento
        uri = URI.parse(@@url_moip_autorizar_pagamento)
        request = Net::HTTP::Put.new(uri.path)
        request.body = dado
      when :consultar_instrucao
        uri = URI.parse(@@url_moip_consultar_instrucao + "/#{dado}")
        request = Net::HTTP::Get.new(uri.path)
      end
        
      key = Base64.encode64(@@token_moip+":"+@@chave_moip).gsub(/\s/i, '')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request.content_type = 'text/xml'
      request['Authorization'] = "Basic "+key

      puts "\n==\n Chamada: #{request.body}"

      response = http.request(request)
      puts "\n==\n Resposta: #{response.body}"

      return response
    end

    @@paypal_user = "seller_1341454687_biz_api1.gmail.com"
    @@paypal_password = "RY8G7F7GZDAPQKST"
    @@paypal_signature = "An5ns1Kso7MWUdW4ErQKJJJ4qi4-AI5KxgmJroLS1ZMQ0b4ymG1Y07Lj "
    @@paypal_nvp_url = "https://api-3t.sandbox.paypal.com/nvp"

    def self.chamada_paypal metodo, valores
      default_values = {
        'USER' => @@paypal_user,
        'PWD' => @@paypal_password,
        'SIGNATURE' => @@paypal_signature,
        'VERSION' => '89.0',
        'REQCONFIRMSHIPPING' => '0',
        'NOSHIPPING' => '1',
        'METHOD' => metodo,
        'SOLUTIONTYPE' => 'Sole',
        'LANDINGPAGE' => 'Billing',
        'LOCALECODE' => 'BR'
      }

      uri = URI.parse(@@paypal_nvp_url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path)
      request.form_data = default_values.deep_merge(valores)

      puts "\n==\n Chamada: #{request.body}"

      response = http.request(request)
      response = URI.unescape(response.body).split('&')

      response_hash = {}
      response.each do |parte|
        chave, valor = parte.split('=')
        response_hash[chave] = valor
      end

      puts "\n==\n Resposta: #{response_hash}"
      
      return response_hash
    end

  end
end