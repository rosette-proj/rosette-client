# encoding: UTF-8

require 'cgi'
require 'net/http'
require 'json'

module Rosette
  module Client

    class ApiError < StandardError; end

    class Api
      DEFAULT_HOST = 'localhost'
      DEFAULT_PORT = 8080
      DEFAULT_VERSION = 'v1'

      attr_reader :host, :port, :version

      def initialize(options = {})
        @host = options.fetch(:host, DEFAULT_HOST)
        @port = options.fetch(:port, DEFAULT_PORT)
        @version = options.fetch(:version, DEFAULT_VERSION)
      end

      def diff(params)
        wrap(make_request(:get, 'git/diff.json', params))
      end

      def show(params)
        wrap(make_request(:get, 'git/show.json', params))
      end

      def status(params)
        wrap(make_request(:get, 'git/status.json', params))
      end

      def commit(params)
        wrap(make_request(:get, 'git/commit.json', params))
      end

      def snapshot(params)
        wrap(make_request(:get, 'git/snapshot.json', params))
      end

      def repo_snapshot(params)
        wrap(make_request(:get, 'git/repo_snapshot.json', params))
      end

      def add_or_update_translation(params)
        wrap(make_request(:post, 'translations/add_or_update.json', params))
      end

      private

      def wrap(api_response)
        Response.from_api_response(api_response)
      end

      def base_url
        "http://#{host}:#{port}/#{version}"
      end

      def make_request(verb, path, params)
        parse_response(
          case verb
            when :post
              url = make_post_url(path, params)
              post(url, params)
            when :get
              url = make_get_url(path, params)
              get(url)
            else
              raise ArgumentError, "unsupported HTTP verb #{verb}."
          end
        )
      rescue => e
        raise ApiError, e.message
      end

      def parse_response(response)
        JSON.parse(response)
      end

      def make_param_string(params)
        (params.map do |key, val|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(val.to_s)}"
        end).join("&")
      end

      def make_get_url(path, params)
        File.join(base_url, path, "?#{make_param_string(params)}")
      end

      def make_post_url(path, params, path_params)
        File.join(base_url, path)
      end

      def post(url, params)
        uri = parse_uri(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path)
        request.body = make_param_string(params)
        resp = http.request(request)
        resp.body
      end

      def get(url)
        resp = Net::HTTP.get_response(parse_uri(url))
        resp.body
      end

      # hack to handle bug in URI.parse, which doesn't allow subdomains to contain underscores
      def parse_uri(url = nil)
        URI.parse(url)
      rescue URI::InvalidURIError
        host = url.match(".+\:\/\/([^\/]+)")[1]
        uri = URI.parse(url.sub(host, 'dummy-host'))
        uri.instance_variable_set('@host', host)
        uri
      end
    end

  end
end
