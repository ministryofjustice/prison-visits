RSpec.shared_examples "prison slots and data" do
  let(:slots_for_everyday) do
    {
      "mon" => ["1400-1600"],
      "tue" => ["1400-1600"],
      "wed" => ["1400-1600"],
      "thu" => ["1400-1600"],
      "fri" => ["1400-1600"],
      "sat" => ["0930-1130", "1400-1600"],
      "sun" => ["1400-1600"]
    }
  end

  let(:prison_data) do
    {
      "nomis_id" => "RCI",
      "canned_responses" => true,
      "enabled" => true,
      "phone" => "01634 803100",
      "email" => "pvb.rochester@maildrop.dsd.io",
      "instant_booking" => false,
      "address" => ["1 Fort Road", "Rochester", "Kent", "ME1 3QS"],
      "unbookable" => [],
      "slot_anomalies" => {},
      "slots" => slots_for_everyday
    }
  end

  let(:mock_slots_data) do
    slots_for_everyday.merge("sat" => ["0930-1130", "1400-1600"])
  end

  let(:mock_prison_data) do
    prison_data.merge(
      "lead_days" => 4,
      "booking_window" => 14,
      "works_weekends" => true,
      "unbookable" => [Date.new(2015, 7, 29), Date.new(2015, 12, 25)],
      "slot_anomalies" => { Date.new(2015, 8, 14) => ["0700-0900"] },
      "slots" => mock_slots_data
    )
  end
end
