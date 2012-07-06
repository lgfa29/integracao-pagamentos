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
		@festa = Produto.find(params['id'])

		pedido = {
			'PAYMENTREQUEST_0_AMT' => @festa.preco,
			'PAYMENTREQUEST_0_CURRENCYCODE' => 'BRL',
			'RETURNURL' => url_for(:action => 'confirmar', :id_festa => @festa.id.to_s, :only_path => false),
			'CANCELURL' => url_for(:action => 'cancelar', :only_path => false),
			'PAYMENTREQUEST_0_ITEMAMT' => @festa.preco,
			'L_PAYMENTREQUEST_0_NAME0' => @festa.nome,
			'L_PAYMENTREQUEST_0_AMT0' => @festa.preco,
			'L_PAYMENTREQUEST_0_QTY0' => '1',
			'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital'
		}
		
		response = WebServiceClient::WebServiceFacade.chamada_paypal 'SetExpressCheckout', pedido

		if response['ACK'] == 'Success'
			redirect_to "https://www.sandbox.paypal.com/incontext?token="+response['TOKEN']
		else
			flash[:error] = "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			redirect_to :action => 'detalhes', :id => @festa.id
		end
	end

	def confirmar
		puts "\n==\nParams: #{params}"

		@festa = Produto.find(params['id_festa'])

		pedido = {
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

		response = WebServiceClient::WebServiceFacade.chamada_paypal 'DoExpressCheckoutPayment', pedido

		if response['ACK'] == 'Success'
			Pedido.create({
				:id_transacao => response['PAYMENTINFO_0_TRANSACTIONID'],
				:id_produto => @festa.id,
				:estornado => false })
			
			redirect_to :action => 'concluido'
		else
			flash[:error] = "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
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
		@festa = Produto.find(params[:id])

		begin
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

	private
		def reembolsar_compradores id_produto
			Pedido.where(:id_produto => id_produto).each do |pedido|
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
end