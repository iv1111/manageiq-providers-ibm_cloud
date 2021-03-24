class ManageIQ::Providers::IbmCloud::Inventory::Persister < ManageIQ::Providers::Inventory::Persister::ObjectStorage
  require_nested :ObjectStorage
  require_nested :PowerVirtualServers
  require_nested :VPC
end
