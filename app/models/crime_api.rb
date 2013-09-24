class CrimeAPI

  APIURL = "http://crimestats.mohawkapps.com/nc/winston-salem/?date="

  def self.dataForDate(date, &block)

    BW::HTTP.get(APIURL + date) do |response|
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
