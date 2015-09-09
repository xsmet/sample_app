if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider              => 'AWS',                  #required
      :aws_access_key_id     => ENV['S3_ACCESS_KEY'],   #required
      :aws_secret_access_key => ENV['S3_SECRET_KEY'],   #required
      :region                => 'eu-central-1',         #optional, default 'us-east-1', eu-central is Frankfurt
      :aws_signature_version => '4'                     #optional? default probably 4
    }
    config.fog_directory     =  ENV['S3_BUCKET']        #required
  end
end

#   :host                   => 's3.example.com',             #optional, default nil
#   :endpoint               => 'https://s3.example.com:8080' #optional, default nil
# config.root = Rails.root.join('tmp') # adding these...
# config.cache_dir = 'carrierwave' # ...two lines
# config.fog_public     = false                                   #optional, default true
# config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  #optional, default {}
