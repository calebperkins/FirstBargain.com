# encoding: utf-8

class MainPictureUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::ImageScience
  include CarrierWave::Compatibility::Paperclip
  
  storage :file
  
  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end

  version :thumb do
    process :resize_to_fit => [70, 65]
  end
  
  version :small do
    process :resize_to_fit => [120, 110]
  end
  
  version :medium do
    process :resize_to_fit => [280, 260]
  end
  
  version :index do
    process :resize_to_fit => [220, 204]
  end
    
  def extension_white_list
     %w(jpg jpeg gif png)
  end

end
