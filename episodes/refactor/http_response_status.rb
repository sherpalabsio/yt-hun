class CalendarService::Client < HTTPClient
  def create_event(event_params)
    response = request(:post, "events", body: event_params)

    if [200, 201].include?(response.status)
      return response.body
    else
      raise RequestError, response
    end
  end

  def update_event(id, event_params)
    response = request(:patch, "events/#{id}", body: event_params)

    if [200, 204].include?(response.status)
      return response.body
    else
      raise RequestError, response
    end
  end

  def delete_event(id)
    response = request(:delete, "events/#{id}")

    if [200, 204].include?(response.status)
      return response.body
    else
      raise RequestError, response
    end
  end
end
