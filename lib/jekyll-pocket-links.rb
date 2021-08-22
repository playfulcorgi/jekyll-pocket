require 'jekyll'
require 'net/http'
require 'uri'
require 'json'
require 'jekyll_pocket_links/pocket_error'

module JekyllPocketLinks
  class RenderPocketTag < Liquid::Tag
    def fetchPocketList(pocket_access_token, pocket_consumer_key)
      pocket_get_uri = 'https://getpocket.com/v3/get'

      pocket_get_options = @options.select {|_key, value| !value.nil? }

      pocket_response = Net::HTTP.post(
        URI(pocket_get_uri),
        {
          "access_token" => pocket_access_token,
          "consumer_key" => pocket_consumer_key
        }.merge(pocket_get_options).to_json,
        {
          "Content-Type" => "application/json",
          'X-Accept': 'application/json'
        }
      )

      if !pocket_response.is_a?(Net::HTTPSuccess)
        puts pocket_response

        raise ::JekyllPocketLinks::PocketError.new(pocket_response)
      end

      JSON.parse(pocket_response.body)['list']
    end

    def preparePocketListForTemplate(pocket_list)
      pocket_list
        .map { |item_id, item_value| item_value }
        .map do |item_value|
          item_value.map do |item_value_key, item_value_value|
            if item_value_key =~ /\Atime_/
              [item_value_key, Time.at(item_value_value.to_i)]
            else
              [item_value_key, item_value_value]
            end
          end
          .to_h
        end
    end

    def getTemplate
      custom_template_path = File.join Dir.pwd, '_includes', 'pocket.html'

      if File.exist?(custom_template_path)
        template = File.read custom_template_path
      else
        template_path = File.join __dir__, '_includes', 'pocket.html'
        template = File.read template_path
      end

      Liquid::Template.parse template
    end

    def renderTemplate(context, pocket_list)
      site = context.registers[:site]

      payload = Jekyll::Utils.deep_merge_hashes(
        site.site_payload,
        # Copy context['page'] from Jekyll to pocket.html template context
        # so it's available for custom Liquid tags inside it.
        'page' => context['page'],
        'pocket_list' => pocket_list
      )

      getTemplate.render!(payload)
    end

    def render(context)
      puts "Fetching list from Pocket service."

      pocket_access_token = ENV['JEKYLL_POCKET_ACCESS_TOKEN']
      pocket_consumer_key = ENV['JEKYLL_POCKET_CONSUMER_KEY']
      pocket_list = fetchPocketList(pocket_access_token, pocket_consumer_key)

      ordered_pocket_list = preparePocketListForTemplate(pocket_list)
      
      renderTemplate(context, ordered_pocket_list)
    end

    def initialize(tag_name, custom_options_string, context)
      super

      default_options = {
        count: 10,
        offset: 0,
        tag: nil,
        state: nil,
        favorite: nil,
        sort: nil
      }

      custom_options = custom_options_string.empty? ? {} : JSON.parse(custom_options_string)

      @options = default_options.merge(custom_options)
    end

    Liquid::Template.register_tag "pocket", self
  end
end
