# encoding: UTF-8

class PaypalController < ApplicationController
	def index
	end

	def digital_goods_express_checkout
	end

	def checkout
		pedido = {
			'PAYMENTREQUEST_0_AMT' => '120.00',
			'PAYMENTREQUEST_0_CURRENCYCODE' => 'BRL',
			'RETURNURL' => url_for(:action => 'confirmar', :only_path => false),
			'CANCELURL' => url_for(:action => 'cancelar', :only_path => false),
			'PAYMENTREQUEST_0_ITEMAMT' => '120.00',
			'L_PAYMENTREQUEST_0_NAME0' => 'Barra de Cereal',
			'L_PAYMENTREQUEST_0_AMT0' => '1.20',
			'L_PAYMENTREQUEST_0_QTY0' => '100',
			'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital'
		}
		
		response = WebServiceClient::WebServiceFacade.chamada_paypal 'SetExpressCheckout', pedido

		if response['ACK'] == 'Success'
			redirect_to "https://www.sandbox.paypal.com/incontext?token="+response['TOKEN']
		else
			flash[:error] = "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			redirect_to :action => 'digital_goods_express_checkout'
		end
	end

	def confirmar
		puts "\n==\nParams: #{params}"

		detalhes = WebServiceClient::WebServiceFacade.chamada_paypal 'GetExpressCheckoutDetails', {'TOKEN' => params['token']}
		puts "\n==\nDetalhes: #{detalhes}"

		pedido = {
			'TOKEN' => params['token'],
			'PAYERID' => params['PayerID'],
			'PAYMENTREQUEST_0_AMT' => detalhes['AMT'],
			'PAYMENTREQUEST_0_CURRENCYCODE' => 'BRL',
			'PAYMENTREQUEST_0_ITEMAMT' => detalhes['ITEMAMT'],
			'L_PAYMENTREQUEST_0_NAME0' => 'Barra de Cereal',
			'L_PAYMENTREQUEST_0_AMT0' => '1.20',
			'L_PAYMENTREQUEST_0_QTY0' => '100',
			'L_PAYMENTREQUEST_0_ITEMCATEGORY0' => 'Digital'
		}

		response = WebServiceClient::WebServiceFacade.chamada_paypal 'DoExpressCheckoutPayment', pedido

		if response['ACK'] == 'Success'
			flash[:success] = "Pedido concluido com sucesso."
			redirect_to :action => 'concluido'
		else
			flash[:error] = "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
			redirect_to :action => 'digital_goods_express_checkout'
		end
	end

	def concluido
		flash[:success] = "Pedido concluido com sucesso."
	end

	def cancelar
		flash[:success] = "Pedido cancelado."
		render :action => 'concluido'
	end

	def estorno
	end

	def realizar_estorno
		pedido = {
			'TRANSACTIONID' => params['id_transferencia'],
			'REFUNDTYPE' => 'Full'
		}

		response = WebServiceClient::WebServiceFacade.chamada_paypal 'RefundTransaction', pedido

		if response['ACK'] == 'Success'
			flash[:success] = "Pedido estornado com sucesso."
		else
			flash[:error] = "Erro #{response['L_ERRORCODE0']}: #{response['L_SHORTMESSAGE0']}. #{response['L_LONGMESSAGE0']}"
		end

		redirect_to :action => 'estorno'
	end
end