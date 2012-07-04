# encoding: UTF-8

class MoipController < ApplicationController

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

		response = WebServiceClient::WebServiceFacade.chamada_moip xml, :instrucao_unica
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

		response = WebServiceClient::WebServiceFacade.chamada_moip xml, :instrucao_unica
		xml = Nokogiri::XML.parse(response.body)

		status = xml.xpath('//Resposta/Status').text

		if status == 'Sucesso'
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

	def autorizar_ou_cancelar_pedido
	end

	def realizar_acao
		codigo_pedido = params[:codigo_pedido]
		acao = params[:acao]

		if acao == 'autorizar'
			xml = %Q(
				<AutorizarPagamento>
					<Codigo>#{codigo_pedido}</Codigo>
				</AutorizarPagamento>)
			response = WebServiceClient::WebServiceFacade.chamada_moip xml, :autorizar_pagamento
			mensagem_sucesso = 'Pagamento autorizado com sucesso.'
		else
			xml = %Q(
				<CancelarPagamento>
					<Codigo>#{codigo_pedido}</Codigo>
				</CancelarPagamento>)
			response = WebServiceClient::WebServiceFacade.chamada_moip xml, :cancelar_pagamento
			mensagem_sucesso = 'Pagamento cancelado com sucesso.'
		end
		xml = Nokogiri::XML.parse(response.body)

		status = xml.xpath('//Resposta/Status').text
		if status == 'Sucesso'
			flash[:success] = mensagem_sucesso
		else
			flash[:error] = xml.xpath('//Resposta/Erro').text
		end

		redirect_to :action => 'autorizar_ou_cancelar_pedido'
	end
end