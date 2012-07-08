# encoding: UTF-8

class LojaVirtualController < ApplicationController
	def index
	end

	def lista
		@festas = Produto.where(:ativo => true)
	end

	def detalhes
		@festa = Produto.find(params['id'])
	end

	def checkout
		begin
			@festa = Produto.find(params['id'])
			token = obter_token_para_pedido @festa
			redirect_to "https://www.sandbox.paypal.com/incontext?token="+token
		rescue => e
			flash[:error] = e.message
			redirect_to :action => 'detalhes', :id => @festa.id
		end
	end

	def confirmar
		begin
			@festa = Produto.find(params['id_festa'])

			id_transacao = confirmar_pagamento_e_obter_id_transacao params

			Pedido.create({
				:id_transacao => id_transacao,
				:id_produto => @festa.id,
				:estornado => false })
			
			redirect_to :action => 'concluido'
		rescue => e
			flash[:error] = e.message
			redirect_to :action => 'detalhes', :id => @festa.id
		end
	end

	def concluido
		flash[:success] = "Pedido concluido com sucesso."
	end

	def cancelar
		flash[:success] = "Pedido cancelado."
		render :action => 'concluido'
	end


	def cancelar_festa
		@festas_ativas = Produto.where(:ativo => true)
		@festas_canceladas = Produto.where(:ativo => false)
	end

	def realizar_cancelamento
		begin
			@festa = Produto.find(params[:id])

			reembolsar_compradores @festa.id

			@festa.ativo = false
			@festa.save

			flash[:success] = 'Festa cancelada com sucesso.'
		rescue => e
			flash[:error] = e.message
		end

		redirect_to :action => 'cancelar_festa'
	end

	def realizar_ativamento
		@festa = Produto.find(params[:id])
		@festa.ativo = true
		@festa.save

		flash[:success] = 'Festa ativada com sucesso.'
		redirect_to :action => 'cancelar_festa'
	end


	def lista_pedidos
		@pedidos = Pedido.all
	end

	def detalhes_pedido
		pedido = Pedido.where(:id_transacao => params[:id])[0]
		
		@detalhes_pedido = obter_detalhes_da_transacao pedido.id_transacao
		@festa = Produto.find pedido.id_produto
	end

	private
		def obter_token_para_pedido festa
			dados_pedido = {
				'PAYMENTREQUEST_0_AMT' => festa.preco,
				'PAYMENTREQUEST_0_CURRENCYCODE' => 'BRL',
				'RETURNURL' => url_for(:action => 'confirmar', :id_festa => festa.id.to_s, :only_path => false),
				'CANCELURL' => url_for(:action => 'cancelar', :only_path => false),
				'PAYMENTREQUEST_0_ITEMAMT' => festa.preco,
				'L_PAYMENTREQUEST_0_NAME0' => festa.nome,
				'L_PAYMENTREQUEST_0_AMT0' => festa.preco,
				'L_PAYMENTREQUEST_0_QTY0' => '1',
				'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital'
			}
			
			response = WebServiceClient::WebServiceFacade.chamada_paypal 'SetExpressCheckout', dados_pedido
			if response['ACK'] != 'Success'
				raise "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			end

			return response['TOKEN']
		end

		def confirmar_pagamento_e_obter_id_transacao params
			dados_pedido = {
				'TOKEN' => params['token'],
				'PAYERID' => params['PayerID'],
				'PAYMENTREQUEST_0_AMT' => @festa.preco,
				'PAYMENTREQUEST_0_CURRENCYCODE' => 'BRL',
				'PAYMENTREQUEST_0_ITEMAMT' => @festa.preco,
				'L_PAYMENTREQUEST_0_NAME0' => @festa.nome,
				'L_PAYMENTREQUEST_0_AMT0' => @festa.preco,
				'L_PAYMENTREQUEST_0_QTY0' => '1',
				'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital'
			}

			response = WebServiceClient::WebServiceFacade.chamada_paypal 'DoExpressCheckoutPayment', dados_pedido
			if response['ACK'] != 'Success'
				raise "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			end

			return response['PAYMENTINFO_0_TRANSACTIONID']
		end

		def reembolsar_compradores id_produto
			Pedido.where(:id_produto => id_produto, :estornado => false).each do |pedido|
				dados_chamada = {
					'TRANSACTIONID' => pedido.id_transacao,
					'REFUNDTYPE' => 'Full'
				}
				
				response = WebServiceClient::WebServiceFacade.chamada_paypal 'RefundTransaction', dados_chamada
				if response['ACK'] != 'Success'
					raise "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
				end

				pedido.estornado = true
				pedido.save
			end
		end

		def obter_detalhes_da_transacao id_transacao
			response = WebServiceClient::WebServiceFacade.chamada_paypal 'GetTransactionDetails', {'TRANSACTIONID' => id_transacao}

			if response['ACK'] != 'Success'
				raise "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			end

			return response
		end

end