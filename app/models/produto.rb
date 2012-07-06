class Produto
	include Mongoid::Document

	field :nome, :type => String
	field :descricao, :type => String
	field :local, :type => String
	field :dia, :type => Integer
	field :mes, :type => Integer
	field :ano, :type => Integer
	field :preco, :type => String
	field :ativo, :type => Boolean

	def data
		return sprintf("%02d", self.dia)+'/'+sprintf("%02d", self.mes)+'/'+self.ano.to_s
	end

end