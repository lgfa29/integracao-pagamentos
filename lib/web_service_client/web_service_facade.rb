module WebServiceClient
	class WebServiceFacade

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

	end
end