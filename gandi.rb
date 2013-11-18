require 'xmlrpc/client'
require 'optparse'

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


def main()
    server = XMLRPC::Client.new2('https://rpc.gandi.net/xmlrpc/')
    server.http_header_extra = { "Accept-Encoding" => "gzip" }
    server.set_parser ZlibParserDecorator.new(server.send(:parser))

    ## 24-character API needs to be set as an environment variable
    apikey = ENV['GANDI_API_KEY']  

    api_version = server.call("version.info", apikey)
    puts "Using API version #{api_version['api_version']}"


    options = get_command_line_options


    #if options[:create]
        # create a new forward
    if options[:list]
        puts get_current_forwards(apikey, server, options[:fqdn])
    end

    return server
end

def get_current_forwards(apikey, server, fqdn)
    forward_list = server.call("domain.forward.list", apikey, fqdn)
    return forward_list
end

def get_domains(apikey, server)
    domain_list = server.call("domain.list", apikey)
    fqdn_list = []

    domain_list.each do |d|
        fqdn_list << d["fqdn"]
    end

    return fqdn_list
end

def get_command_line_options
    options = {}

    # special case for personal use :)
    # can be overridden with -f "fqdn.com"
    options[:fqdn] = "isaacdontjelindell.com"

    OptionParser.new do |opts|
        opts.banner = "Usage: gandi.rb [options]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            options[:verbose] = v
        end

        opts.on("-c", "--create 'from@test.com to@test.com'", "create a new forwarding address") do |s|
            addresses = s.split      
            options[:create] = true
            options[:from] = addresses[0]
            options[:to] = addresses[1]
        end

        opts.on("-l", "--list", "list all existing forwards") do
            options[:list] = true
        end

        opts.on("-f", "--fqdn FQDN", "specify the domain to administrate") do |fqdn|
            options[:fqdn] = fqdn
        end
        
    end.parse!

    p options
    return options
end


main()
