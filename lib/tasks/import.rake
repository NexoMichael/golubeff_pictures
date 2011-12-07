namespace :import do
  task :lolpix => :environment do
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    host = "http://www.lolpix.com"
    page = agent.get("#{host}/pictures.asp")

    latest_id = nil
    page.search('.gallery li a').reverse.each do |link|
      uri = link.attribute('href')
      id = uri.to_s.scan(/(\d+)\.htm/).flatten[0]
      if id.nil?
        id = latest_id.to_i + 1
        uri = "/_pics/Funny_Pictures_#{id}.htm"
      end
      latest_id = id

      referral_url = "#{host}#{uri}"
      date_page = agent.get(referral_url)
      date_page.search('.gallery li a img').each do |img|
        image_url = "#{host}#{img.attribute('src').to_s.gsub(/_s\./, '.')}"
        next if ImportLog.exists?(:key => "lolpix", :url => image_url)

        ActiveRecord::Base.transaction do
          Picture.create :source_url => image_url, :referral_url => referral_url
          ImportLog.create :key => "lolpix", :url => image_url
        end
      end
    end
  end

  task :eatliver => :environment do
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    host = "http://www.eatliver.com"
    page = agent.get("#{host}")

    page.search('.update a').each do |link|
      referral_url = "#{host}/#{link.attribute('href')}"

      link.search('img').each do |img|
        image_url = "#{host}/#{img.attribute('src').to_s.gsub(/small\//, '')}"
        next if ImportLog.exists?(:key => "eatliver", :url => image_url)

        ActiveRecord::Base.transaction do
          Picture.create :source_url => image_url, :referral_url => referral_url
          ImportLog.create :key => "eatliver", :url => image_url
        end
      end
    end
  end

  task :veryfunnypics => :environment do
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    host = "http://www.veryfunnypics.com"
    page = agent.get("#{host}/index.php")

    page.search('.picBox a').each do |link|
      referral_url = "#{host}#{link.attribute('href')}"

      link.search('img').each do |img|
        image_url = "#{host}#{img.attribute('src')}"
        next if ImportLog.exists?(:key => "veryfunnypics", :url => image_url) or not image_url.end_with?(".jpg")

        ActiveRecord::Base.transaction do
          Picture.create :source_url => image_url, :referral_url => referral_url
          ImportLog.create :key => "veryfunnypics", :url => image_url
        end
      end
    end
  end

end
