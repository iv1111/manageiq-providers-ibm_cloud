class ManageIQ::Providers::IbmCloud::ObjectStorage::StorageManager < ManageIQ::Providers::StorageManager
  require_nested :Refresher
  require_nested :RefreshWorker

  supports :ems_storage_new
  include ManageIQ::Providers::StorageManager::ObjectMixin

  def self.params_for_create
    @params_for_create ||= {
      :component              => 'validate-provider-credentials',
      :id                     => 'endpoints.default.valid',
      :name                   => 'endpoints.default.valid',
      :skipSubmit             => true,
      :isRequired             => true,
      :fields                 => [
          {
            :component  => "text-field",
            :name       => "provider_region",
            :id         => "provider_region",
            :label      => _("Region"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
          },
          {
            :component  => "text-field",
            :name       => "uid_ems",
            :id         => "uid_ems",
            :label      => _("Resource Instance Id"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
          },
          {
            :component  => "text-field",
            :name       => "endpoints.default.url",
            :label      => _("Endpoint"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
          },
          {
            :component  => "text-field",
            :name       => "authentications.default.auth_key",
            :id         => "authentications.default.auth_key",
            :label      => _("Apikey"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
            :type       => "password",
          },
          {
            :component  => "text-field",
            :name       => "authentications.bearer.userid",
            :id         => "authentications.bearer.userid",
            :label      => _("Access Key"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
            :type       => "password",
          },
          {
            :component  => "text-field",
            :name       => "authentications.bearer.password",
            :id         => "authentications.bearer.password",
            :label      => _("Secret Key"),
            :isRequired => true,
            :validate   => [{:type => "required"}],
            :type       => "password",
          }
      ]
    }
  end

  def verify_bearer
    begin
      connect(nil).list_buckets(:max_results => 1)
    rescue IbmCloudIam::ApiError => err
      error_message = JSON.parse(err.response_body)["message"]
      _log.error("Access/Secret authentication failed: #{err.code} #{error_message}")
      raise MiqException::MiqInvalidCredentialsError, error_message
    end
  end

  def verify_iam
    begin
      require "ibm_cloud_iam"
      iam_token_api = IbmCloudIam::TokenOperationsApi.new
      iam_token_api.get_token_api_key("urn:ibm:params:oauth:grant-type:apikey", api_key)
    rescue IbmCloudIam::ApiError => err
      error_message = JSON.parse(err.response_body)["message"]
      _log.error("IAM authentication failed: #{err.code} #{error_message}")
      raise MiqException::MiqInvalidCredentialsError, error_message
    end
  end

  def self.hostname_required?
    false
  end

  def self.ems_type
    @ems_type ||= "ibm_cloud_object_storage".freeze
  end

  def self.description
    @description ||= "IBM Cloud Object Storage".freeze
  end

  def self.raw_connect(region, endpoint, access_key, secret_key)
    require "aws-sdk-s3"

    options = {
      :credentials   => Aws::Credentials.new(access_key, secret_key),
      :region        => region,
      :logger        => $ibm_cloud_log,
      :log_level     => :debug,
      :log_formatter => Aws::Log::Formatter.new(Aws::Log::Formatter.default.pattern.chomp),
      :endpoint      => endpoint,
    }

    Aws.const_get(:S3)::Resource.new(options)
  end

  def connect(_options)
    bearer = get_auth_node('bearer')
    connection = self.class.raw_connect(provider_region, default_endpoint.url, bearer[:access_key], bearer[:secret_key])
    return connection.client
  end

  def get_auth_node(node)
    authentications.detect { |e| e.authtype == node } || {}
  end

  def get_cos_creds
    default = get_auth_node('default')
    bearer  = get_auth_node('bearer')

    cos_ans_creds = {resource_instance_id: uid_ems, apikey: default.auth_key}
    cos_pvs_creds = {region: provider_region, accessKey: bearer.userid, secretKey: bearer.auth_key}

    return cos_ans_creds, cos_pvs_creds
  end

  def verify_credentials(_options)
    verify_iam
    verify_bearer
  end

  def image_name
    "ibm"
  end
end