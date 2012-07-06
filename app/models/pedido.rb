class Pedido
	include Mongoid::Document

	field :id_transacao, :type => String
	field :id_produto, :type => String

end