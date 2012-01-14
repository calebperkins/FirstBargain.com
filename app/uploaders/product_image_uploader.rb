# encoding: utf-8

class ProductImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::ImageScience
  include CarrierWave::Compatibility::Paperclip

  storage :file
  
  def paperclip_path
    ":rails_root/public/system/datas/:id/:style/:basename.:extension"
  end

  version :thumb do
     process :resize_to_fit => [70, 65]
  end
  
  version :medium do
    process :resize_to_fit => [280, 260]
  end

  def extension_white_list
     %w(jpg jpeg gif png)
  end

end
