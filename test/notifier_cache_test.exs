defmodule NotifierCacheTest do
  use ExUnit.Case, async: false

  alias MinBlagoBot.Services.SnowNotificator.Cache

  setup do
    Cache.clear_started()
    Cache.clear_time_passed()
    Process.sleep(100)
  end

  test "started: put into cache" do
    data = [
      one = %{short_name: "one", snowfall_started: Timex.local()},
      two = %{short_name: "two", snowfall_started: Timex.local()},
      three = %{short_name: "three", snowfall_started: Timex.local()}
    ]

    Cache.add_notified_about_start(data)

    assert Cache.is_notified_about_start?(one)
    assert Cache.is_notified_about_start?(two)
    assert Cache.is_notified_about_start?(three)
    refute Cache.is_notified_about_start?(%{short_name: "nope", snowfall_started: Timex.local()})
  end

  test "started: mark as notifiction sended" do
    actual_data = [
      one = %{short_name: "one", snowfall_started: Timex.local()},
      two = %{short_name: "two", snowfall_started: Timex.local()}
    ]

    data_to_add = [
      four = %{short_name: "four", snowfall_started: Timex.local()}
    ]

    Cache.add_notified_about_start(actual_data)

    assert Cache.is_notified_about_start?(one)
    assert Cache.is_notified_about_start?(two)
    refute Cache.is_notified_about_start?(four)

    Cache.add_notified_about_start(data_to_add)


    assert Cache.is_notified_about_start?(one)
    assert Cache.is_notified_about_start?(two)
    assert Cache.is_notified_about_start?(four)
  end

  test "started: remove obsolete" do
    obsolete_data = [
      one = %{short_name: "one", snowfall_started: Timex.local()},
      two = %{short_name: "two", snowfall_started: Timex.local()},
      three = %{short_name: "three", snowfall_started: Timex.local()}
    ]

    actual_data = [
      one,
      two,
      four = %{short_name: "four", snowfall_started: Timex.local()}
    ]

    Cache.add_notified_about_start(obsolete_data)

    Cache.remove_obsolete_started(actual_data)

    assert Cache.is_notified_about_start?(one)
    assert Cache.is_notified_about_start?(two)
    refute Cache.is_notified_about_start?(four)
    refute Cache.is_notified_about_start?(three)
  end

  test "time passed: mark as notifiction sended" do
    time = Timex.local() |> Timex.shift(hours: -3)

    actual_data = [
      one = %{short_name: "one", snowfall_started: time},
      two = %{short_name: "two", snowfall_started: time}
    ]

    data_to_add = [
      four = %{short_name: "four", snowfall_started: time}
    ]

    Cache.add_notified_time_passed(actual_data)

    assert Cache.is_notified_time_passed?(one)
    assert Cache.is_notified_time_passed?(two)
    refute Cache.is_notified_time_passed?(four)

    Cache.add_notified_time_passed(data_to_add)

    assert Cache.is_notified_time_passed?(one)
    assert Cache.is_notified_time_passed?(two)
    assert Cache.is_notified_time_passed?(four)
  end

  test "time passed: put into cache" do
    time = Timex.local() |> Timex.shift(hours: -3)

    data = [
      one = %{short_name: "one", snowfall_started: time},
      two = %{short_name: "two", snowfall_started: time},
      three = %{short_name: "three", snowfall_started: time}
    ]

    Cache.add_notified_time_passed(data)

    assert Cache.is_notified_time_passed?(one)
    assert Cache.is_notified_time_passed?(two)
    assert Cache.is_notified_time_passed?(three)
    refute Cache.is_notified_time_passed?(%{short_name: "nope", snowfall_started: time})
  end

  test "time passed: remove obsolete" do
    time = Timex.local() |> Timex.shift(hours: -2)

    obsolete_data = [
      one = %{short_name: "one", snowfall_started: time},
      two = %{short_name: "two", snowfall_started: time},
      three = %{short_name: "three", snowfall_started: time}
    ]

    actual_data = [
      one,
      two,
      four = %{short_name: "four", snowfall_started: time}
    ]

    Cache.add_notified_time_passed(obsolete_data)

    Cache.remove_obsolete_time_passed(actual_data)

    assert Cache.is_notified_time_passed?(one)
    assert Cache.is_notified_time_passed?(two)
    refute Cache.is_notified_time_passed?(four)
    refute Cache.is_notified_time_passed?(three)
  end
end
