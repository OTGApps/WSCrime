class CrimeAPI

  APIURL = "http://crimestats.mohawkapps.com/nc/winston-salem/?date="

  def self.dataForDate(date, &block)
    ap block_given?
    ap block
    BW::HTTP.get(APIURL + date) do |response|
        ap block
        ap date
        ap APIURL

        json = nil
        error = nil

        if response.ok?
          json = BW::JSON.parse(response.body.to_str)
        else
          error = response.error_message
        end

        block.call json, error
    end
  end

end
