# encoding: UTF-8

task :popular => :environment do
	nomes = ['do Chocolate', 'do Pastel', 'do Sushi', 'do Bolo', 'do Bife Com Batata Frita', 'da Picanha', 'da Lasanha', 'da Feijoada', 'do Camrao', 'do Frango Assado']
	eventos = ['Festa', 'Encontro', 'Balada']
	elogios = ['Brilhante', 'Sensacional', 'Mega', 'Supimpa']

	10.times do |i|
		evento = eventos.sample
		nome = nomes[i]
		Produto.create(
			:nome => "#{evento} #{nome}",
			:descricao => "#{elogios.sample} #{evento} com deliciosas opções de #{nome.split[1]}",
			:local => "Rua das Alfazemas, #{rand(100) + 100}",
			:dia => rand(20) + 1,
			:mes => rand(12) + 1,
			:ano => rand(2) + 2012,
			:preco => "%.2f" % (rand(100)+rand(50)+rand).round(2)
		)
	end
end