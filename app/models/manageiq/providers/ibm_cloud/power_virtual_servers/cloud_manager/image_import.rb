module ManageIQ::Providers::IbmCloud::PowerVirtualServers::CloudManager::ImageImport
    def encrypt_with_aes(creds)
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt

      key  = Base64.strict_encode64(cipher.random_key)
      iv   = Base64.strict_encode64(cipher.random_iv)
      encr = Base64.strict_encode64(cipher.update(creds.to_json) + cipher.final)

      [encr, key, iv]
    end

    def miq_img_by_ids(provider_id, image_id)
      powervc = ExtManagementSystem.find(provider_id)
      powervc.get_image_info(image_id)
    end

    def cos_creds(provider_id)
      cos = ExtManagementSystem.find(provider_id)
      cos.cos_creds
    end

    def node_creds(provider_id)
      powervc = ExtManagementSystem.find(provider_id)
      endp = powervc.node_endpoint
      auth = powervc.node_auth

      return endp.hostname, auth.userid, auth.password
    end

    def image_ems_ref(bucket_id)
      MiqTemplate.find(bucket_id).uid_ems
    end

    def bucket_name(bucket_id)
      CloudObjectStoreContainer.find(bucket_id).name
    end
end