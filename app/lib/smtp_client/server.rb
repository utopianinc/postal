# frozen_string_literal: true

module SMTPClient
  class Server

    attr_reader :hostname
    attr_reader :port
    attr_accessor :ssl_mode
    attr_accessor :username
    attr_accessor :password

    def initialize(hostname, port: 25, ssl_mode: SSLModes::AUTO, username: nil, password: nil)
      @hostname = hostname
      @port = port
      @ssl_mode = ssl_mode
      @username = username
      @password = password
    end

    # Return all IP addresses for this server by resolving its hostname.
    # IPv6 addresses will be returned first.
    #
    # @return [Array<SMTPClient::Endpoint>]
    def endpoints
      ips = []

      DNSResolver.local.aaaa(@hostname).each do |ip|
        ips << Endpoint.new(self, ip)
      end

      DNSResolver.local.a(@hostname).each do |ip|
        ips << Endpoint.new(self, ip)
      end

      ips
    end

  end
end
