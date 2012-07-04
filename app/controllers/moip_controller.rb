# encoding: UTF-8

class MoipController < ApplicationController
	require 'nokogiri'
	require 'net/http'

	@@url = "https://desenvolvedor.moip.com.br/sandbox/ws/alpha/EnviarInstrucao/Unica"
	@@token = "ZY8LQJPHOIDWQSSJZBE3SZD73TNNEEVZ"
	@@chave = "ZBT6AW04HEYGIXZFCA7RKO28EFFI8G8MJEFKJOJC"

	def index
	end

	def pagamento_unico
	end

	def realizar_pagamento_unico
		xml = %Q(
		<EnviarInstrucao>
		    <InstrucaoUnica>
		        <Razao>Teste de Pagemento Unico</Razao>
		        <IdProprio>#{Time.now.to_i}</IdProprio>
		        <DataVencimento>#{1.day.from_now.strftime('%Y-%m-%dT%H:%M:%S')}</DataVencimento>

		        <Pagador>
		        	<Nome>#{params["nome"]}</Nome>
		        	<LoginMoIP></LoginMoIP>
		        	<Email>#{params["email"]}</Email>
		        	<TelefoneCelular>#{params["celular"]}</TelefoneCelular>
		        	<Apelido></Apelido>
		        	<Identidade>#{params["cpf"]}</Identidade>
		        	<EnderecoCobranca>
		        		<Logradouro>#{params["logradouro"]}</Logradouro>
			        	<Numero>#{params["numero"]}</Numero>
			        	<Complemento>#{params["complemento"]}</Complemento>
			        	<Bairro>#{params["bairro"]}</Bairro>
			        	<Cidade>#{params["cidade"]}</Cidade>
			        	<Estado>#{params["estado"]}</Estado>
			        	<Pais>BRA</Pais>
			        	<CEP>#{params["cep"]}</CEP>
			        	<TelefoneFixo>#{params["telefone"]}</TelefoneFixo>
					</EnderecoCobranca>	
		        </Pagador>

		        <Valores>
		        	<Valor moeda="BRL">410.50</Valor>
		        </Valores>

		        <URLRetorno>http://localhost:3002/moip/</URLRetorno>

		        <Mensagens>
		        	<Mensagem>Mensagem para o usuário!</Mensagem>
		        </Mensagens>

		    </InstrucaoUnica>
		</EnviarInstrucao>)

		url = URI.parse(@@url)
		key = Base64.encode64(@@token+":"+@@chave).gsub(/\s/i, '')

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true

		request = Net::HTTP::Post.new(url.path)
		request.body = xml
		request.content_type = 'text/xml'
		request['Authorization'] = "Basic "+key

		response = http.request(request)

		xml = Nokogiri::XML.parse(response.body)

		status = xml.xpath('//Resposta/Status').text

		if status == 'Sucesso'
			token = xml.xpath('//Resposta/Token').text
			redirect_to "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=" + token
		else
			flash[:error] = xml.xpath('//Resposta/Erro').text
			redirect_to :action => 'pagamento_unico'
		end
	end

	def checkout_transparente
	end

	def realizar_checkout_transparente
		xml = %Q(
		<EnviarInstrucao>
		    <InstrucaoUnica TipoValidacao="Transparente">
		        <Razao>Teste de Checkout Transparente</Razao>
		        <IdProprio>#{Time.now.to_i}</IdProprio>

		        <Pagador>
		        	<Nome>#{params["nome"]}</Nome>
		        	<Email>#{params["email"]}</Email>
		        	<IdPagador>#{params["email"]}</IdPagador>
		        	<EnderecoCobranca>
		        		<Logradouro>#{params["logradouro"]}</Logradouro>
			        	<Numero>#{params["numero"]}</Numero>
			        	<Complemento>#{params["complemento"]}</Complemento>
			        	<Bairro>#{params["bairro"]}</Bairro>
			        	<Cidade>#{params["cidade"]}</Cidade>
			        	<Estado>#{params["estado"]}</Estado>
			        	<Pais>BRA</Pais>
			        	<CEP>#{params["cep"]}</CEP>
			        	<TelefoneFixo>#{params["telefone"]}</TelefoneFixo>
					</EnderecoCobranca>	
		        </Pagador>

		        <Valores>
		        	<Valor moeda="BRL">410.50</Valor>
		        </Valores>

		    </InstrucaoUnica>
		</EnviarInstrucao>)

		url = URI.parse(@@url)
		key = Base64.encode64(@@token+":"+@@chave).gsub(/\s/i, '')

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true

		request = Net::HTTP::Post.new(url.path)
		request.body = xml
		request.content_type = 'text/xml'
		request['Authorization'] = "Basic "+key

		response = http.request(request)

		puts response.body

		xml = Nokogiri::XML.parse(response.body)

		@status = xml.xpath('//Resposta/Status').text

		if @status == 'Sucesso'
			token = xml.xpath('//Resposta/Token').text
			redirect_to :action => 'checkout_transparente_pagamento', :token => token
		else
			flash[:error] = xml.xpath('//Resposta/Erro').text
			redirect_to :action => 'checkout_transparente'
		end
	end

	def checkout_transparente_pagamento
		@token = params[:token]
	end

	def checkout_transparente_finalizado
		@codigo_moip = params["codigo_moip"]
		@total_pago = params["total_pago"]
		@url = params["url"]
	end
end