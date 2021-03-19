class ManageIQ::Providers::IbmCloud::CloudObjectStorage::StorageManager < ManageIQ::Providers::StorageManager
  require_nested :MetricsCapture
  require_nested :MetricsCollectorWorker
  require_nested :Refresher
  require_nested :RefreshWorker

  supports :ems_storage_new
  include ManageIQ::Providers::StorageManager::ObjectMixin

  def self.ems_type
    @ems_type ||= "cloud_object_storage".freeze
  end

  def self.description
    @description ||= "Cloud Object Storage".freeze
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
      :fields => []
    }
  end
end