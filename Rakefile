namespace 'jekyll-pocket-links' do
  task :get_auth_code, [:consumer_key] do |_task, arguments|
    require 'net/http'
    require 'uri'
    require 'json'

    consumer_key = arguments.consumer_key
    dummy_redirect_uri = "https://this-server-doesnt-exist-but-can-be-used-for-getting-the-auth-code-#{rand(10000..99999)}.com"
    pocket_request_uri = 'https://getpocket.com/v3/oauth/request'

    pocket_response = Net::HTTP.post(
      URI(pocket_request_uri),
      {
        "consumer_key" => consumer_key,
        "redirect_uri" => dummy_redirect_uri
      }.to_json,
      {
        "Content-Type" => "application/json",
        'X-Accept': 'application/json'
      }
    )

    if !pocket_response.is_a?(Net::HTTPSuccess)
      puts pocket_response
      raise ::JekyllPocketLinks::PocketError.new(pocket_response)

      return
    end

    pocket_authentication_code = JSON.parse(pocket_response.body)['code']
    pocket_authorization_base_uri = 'https://getpocket.com/auth/authorize'

    pocket_authorization_uri = URI.parse(pocket_authorization_base_uri)
    pocket_authorization_uri.query = URI.encode_www_form({
      'request_token' => pocket_authentication_code,
      'redirect_uri' => dummy_redirect_uri
    })

    puts %(
      Success! Pocket returned an authentication code.
      Save the authentication code somewhere. It will be needed later.

      Authentication code:
        #{pocket_authentication_code}
      Now visit the following link in your web browser:
        #{pocket_authorization_uri.to_s}
    )
  end

  task :authorize, [:consumer_key, :pocket_authentication_code] do |_task, arguments|
    require 'net/http'
    require 'uri'
    require 'json'

    consumer_key = arguments.consumer_key
    pocket_authentication_code = arguments.pocket_authentication_code

    pocket_authorize_uri = 'https://getpocket.com/v3/oauth/authorize'

    pocket_response = Net::HTTP.post(
      URI(pocket_authorize_uri),
      {
        "consumer_key" => consumer_key,
        "code" => pocket_authentication_code
      }.to_json,
      {
        "Content-Type" => "application/json",
        'X-Accept': 'application/json'
      }
    )

    if !pocket_response.is_a?(Net::HTTPSuccess)
      puts pocket_response

      if pocket_response.code === 403
        if pocket_response.to_hash['x-error-code'] === '159'
          raise ::JekyllPocketLinks::PocketCodeAlreadyUsedError.new(pocket_response)
        end
        
        raise ::JekyllPocketLinks::PocketUnauthorizedError.new(pocket_response)
      end

      raise ::JekyllPocketLinks::PocketError.new(pocket_response)

      return
    end

    pocket_response_data = JSON.parse(pocket_response.body)
    username = pocket_response_data['username']
    access_token = pocket_response_data['access_token']

    puts %(
      Success! Pocket returned an access token and username.
      Save the access token under the environment variable JEKYLL_POCKET_ACCESS_TOKEN
      and the consumer key under JEKYLL_POCKET_CONSUMER_KEY before running Jekyll.

      Account username the links will be fetched from:
        #{username}
      Access token:
        #{access_token}
      Consumer key:
        #{consumer_key}
    )
  end
end
