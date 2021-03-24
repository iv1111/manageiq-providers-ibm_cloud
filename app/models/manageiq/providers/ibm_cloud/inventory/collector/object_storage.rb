class ManageIQ::Providers::IbmCloud::Inventory::Collector::ObjectStorage < ManageIQ::Providers::IbmCloud::Inventory::Collector
  require_nested :StorageManager

  def connection
    @connection ||= manager.connect
  end
end