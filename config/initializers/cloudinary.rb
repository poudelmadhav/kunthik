# Cloudinary configuration for Rails 5.x using ENV URL
if ENV['CLOUDINARY_URL']
  Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
  Cloudinary.config do |config|
    config.secure = true
    config.cdn_subdomain = true
  end
end
