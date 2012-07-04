require "net/http"
require "uri"
require 'base64'

xml = %Q(
<EnviarInstrucao>
    <InstrucaoUnica>
        <Razao>Exemplo</Razao>
        <IdProprio>compra1234</IdProprio>
        <DataVencimento>2008-04-06T12:01:48.703-02:00</DataVencimento>
    </InstrucaoUnica>
</EnviarInstrucao>)

url = URI.parse("https://desenvolvedor.moip.com.br/sandbox/ws/alpha/EnviarInstrucao/Unica")
token='ZY8LQJPHOIDWQSSJZBE3SZD73TNNEEVZ'
chave='ZBT6AW04HEYGIXZFCA7RKO28EFFI8G8MJEFKJOJC'
key = Base64.encode64(token+":"+chave).gsub(/\s/i, '')

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Post.new(url.path)
request.body = xml
request.content_type = 'text/xml'
request['Authorization'] = "Basic "+key

response = http.start {|http| http.request(request) }

puts response