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

    options = get_command_line_options

    if options[:version]
        api_version = server.call("version.info", apikey)
        puts "Using API version #{api_version['api_version']}"
    end
    if options[:list]
        puts get_current_forwards(apikey, server, options)
    end
    if options[:create]
        new_forward = create_new_forward(apikey, server, options)
        puts "Added new forward: #{new_forward}"
        #puts get_current_forwards(apikey, server, options)
    end
    if options[:delete]
        del_forward = delete_existing_forward(apikey, server, options)
        puts "Deleted forward: #{del_forward}"
    end
end

def delete_existing_forward(apikey, server, options)
    source = options[:from]

    return server.call("domain.forward.delete", apikey, options[:fqdn], source)
end

def create_new_forward(apikey, server, options)
    source = options[:from]

    dests = {'destinations' => [options[:to]]}

    return server.call("domain.forward.create", apikey, options[:fqdn], source, dests)
end

def get_current_forwards(apikey, server, options)
    return server.call("domain.forward.list", apikey, options[:fqdn])
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

        opts.on("-v", "--version", "show Gandi API version") do 
            options[:version] = true
        end

        opts.on("-c", "--create 'from@test.com to@test.com'", "create a new forwarding address") do |s|
            addresses = s.split      
            options[:create] = true
            options[:from] = addresses[0]
            options[:to] = addresses[1]
        end

        opts.on("-d", "--delete 'FROM_ADDR'", "delete an existing forwarding address") do |from|
            options[:delete] = true
            options[:from] = from
        end

        opts.on("-l", "--list", "list all existing forwards") do
            options[:list] = true
        end

        opts.on("-f", "--fqdn FQDN", "specify the domain to administrate") do |fqdn|
            options[:fqdn] = fqdn
        end
        
    end.parse!

    return options
end


main()
