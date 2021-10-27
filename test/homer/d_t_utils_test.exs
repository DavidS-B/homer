defmodule Homer.Utils.DTUtilsTest do
  use Homer.DataCase

  import Homer.Utils.DTUtils

  test "minutes_to_time/1" do
    assert "07:05" == minutes_to_time(425)
  end

  test "naive_to_time/1" do
    assert "23:00" == naive_to_time(~N[2000-01-01 23:00:07])
  end

  test "pt_to_minutes/1" do
    minutes_sum = 8 * 60 + 20
    assert minutes_sum == pt_to_minutes("PT8H20M")
  end
end
