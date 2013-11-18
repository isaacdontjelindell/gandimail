require 'xmlrpc/client'

class ZlibParserDecorator
    def initialize(parser)
        @parser = parser
    end
    def parseMethodResponse(responseText)
        @parser.parseMethodResponse(Zlib::GzipReader.new(StringIO.new(responseText)).read)
    end
    def parseMethodCall(*args)
        @parser.parseMethodCall(*args)
    end
end

server = XMLRPC::Client.new2('https://rpc.gandi.net/xmlrpc/')
server.http_header_extra = { "Accept-Encoding" => "gzip" }
server.set_parser ZlibParserDecorator.new(server.send(:parser))

## 24-character API needs to be set as an environment variable
apikey = ENV['GANDI_API_KEY']  


api_version = server.call("version.info", apikey)
puts "Using API version #{api_version['api_version']}"
