module CybozuOffice
  class Response
    attr_reader :raw_response, :service, :method
    def initialize(raw_response, service, method)
      require 'rexml/document'

      @service = service
      @method = method
      @raw_response = raw_response
      @doc = REXML::Document.new(@raw_response)
      @response = nil
    end

    def success?
      @doc.elements['soap:Envelope/soap:Body/soap:Fault'].nil?
    end

    def response
      if @response.nil? then
        response = @doc.elements["soap:Envelope/soap:Body/#{@service.downcase}:#{@method}Response/returns"]
        if Hash.respond_to?(:from_xml) then
          @response = Hash.from_xml(response.to_s)
        else
          require 'xmlsimple'
          @response = XmlSimple.xml_in(response.to_s)
        end
      end
      @response
    end

    def error
      @doc.elements['soap:Envelope/soap:Body/soap:Fault/soap:Reason/soap:Text'].text
    end
  end
end