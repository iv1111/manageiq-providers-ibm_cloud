class ManageIQ::Providers::IbmCloud::CloudObjectStorage::StorageManager::MetricsCollectorWorker < ManageIQ::Providers::BaseManager::MetricsCollectorWorker
  require_nested :Runner

  self.default_queue_name = "cloud_object_storage"

  def friendly_name
    @friendly_name ||= "C&U Metrics Collector for ManageIQ::Providers::IbmCloud::CloudObjectStorage"
  end
end
