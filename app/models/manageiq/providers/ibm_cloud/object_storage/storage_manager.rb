class ManageIQ::Providers::IbmCloud::ObjectStorage::StorageManager < ManageIQ::Providers::StorageManager
  require_nested :Refresher
  require_nested :RefreshWorker

  supports :ems_storage_new
  include ManageIQ::Providers::StorageManager::ObjectMixin

  def self.ems_type
    @ems_type ||= "ibm_cloud_object_storage".freeze
  end

  def self.description
    @description ||= "IBM Cloud Object Storage".freeze
  end

  def self.raw_connect(username, password, host, port)
  end

  def connect(options = {})
  end

  def image_name
    "ibm"
  end

  def self.hostname_required?
    false
  end

  def self.params_for_create
    @params_for_create ||= {
      :fields    => [
        {
          :component  => "text-field",
          :name       => "provider_region",
          :id         => "provider_region",
          :label      => _("Region"),
          :isRequired => false,
        },
        {
          :component  => "text-field",
          :name       => "uid_ems",
          :id         => "uid_ems",
          :label      => _("Resource Instance Id"),
          :isRequired => false,
        },
        {
          :component  => "text-field",
          :name       => "authentications.default.auth_key",
          :id         => "authentications.default.auth_key",
          :label      => _("Apikey"),
          :isRequired => false,
        },
        {
          :component  => "text-field",
          :name       => "authentications.bearer.userid",
          :id         => "authentications.bearer.userid",
          :label      => _("Access Key"),
          :isRequired => false,
        },
        {
          :component  => "text-field",
          :name       => "authentications.bearer.password",
          :id         => "authentications.bearer.password",
          :label      => _("Secret Key"),
          :isRequired => false,
        },
      ]
    }
  end

  def get_cos_creds
    default = authentications.detect { |e| e.authtype == "default" }
    bearer  = authentications.detect { |e| e.authtype == "bearer" }

    cos_ans_creds = {resource_instance_id: uid_ems, apikey: default.auth_key}
    cos_pvs_creds = {region: provider_region, accessKey: bearer.userid, secretKey: bearer.auth_key}

    return cos_ans_creds, cos_pvs_creds
  end
end