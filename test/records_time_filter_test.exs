defmodule RecordsTimeFilterTest do
  use ExUnit.Case

  alias MinBlagoBot.Services.SnowNotificator.RecordsTimeFilter
  test "only time passed" do
    now = Timex.local()
    
    one   = %{short_name: "one", snowfall_started: now}
    two   = %{short_name: "two", snowfall_started: Timex.shift(now, hours: -1)}
    three = %{short_name: "three", snowfall_started: Timex.shift(now, hours: -2)}
    four  = %{short_name: "four", snowfall_started: Timex.shift(now, [hours: -2, seconds: -1])}
    five  = %{short_name: "five", snowfall_started: Timex.shift(now, hours: -3)}
    six   = %{short_name: "six", snowfall_started: Timex.shift(now, hours: -4)}
    list     = [ one, two, three, four, five, six ]
    expected = [                  four, five, six ]
    
    assert RecordsTimeFilter.only_time_passed(list, 2, now) == expected
    assert RecordsTimeFilter.only_time_passed([], 2, now) == []
    assert RecordsTimeFilter.only_time_passed([one, two], 2, now) == []
  end

test "not too old" do
    now = Timex.local()

    one   = %{short_name: "one", snowfall_started: now}
    two   = %{short_name: "two", snowfall_started: Timex.shift(now, hours: -1)}
    three = %{short_name: "three", snowfall_started: Timex.shift(now, hours: -2)}
    four  = %{short_name: "four", snowfall_started: Timex.shift(now, [hours: -2, seconds: -1])}
    five  = %{short_name: "five", snowfall_started: Timex.shift(now, hours: -3)}
    six   = %{short_name: "six", snowfall_started: Timex.shift(now, hours: -4)}
    list     = [ one, two, three, four, five, six ]
    expected = [ one, two ]
    
    assert RecordsTimeFilter.not_too_old(list, 2, now) == expected
    assert RecordsTimeFilter.not_too_old([], 2, now) == []
    assert RecordsTimeFilter.not_too_old([one], 2, now) == [ one ]
  end

end