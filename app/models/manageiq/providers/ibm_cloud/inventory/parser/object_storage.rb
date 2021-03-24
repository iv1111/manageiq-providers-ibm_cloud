class ManageIQ::Providers::IbmCloud::Inventory::Parser::ObjectStorage < ManageIQ::Providers::IbmCloud::Inventory::Parser
  require_nested :StorageManager

  def parse
    cloud_buckets
    cloud_objects
  end

  def cloud_buckets
    # code here
  end

  def cloud_objects
    # code here
  end
end
