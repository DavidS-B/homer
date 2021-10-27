defmodule Homer.Utils.DTUtils do
  @moduledoc """
  This module convert multiple time or datetime format
  """

  @doc """
  Convert minutes to a sliced Time string.

  ## Examples

      iex> minutes_to_time(1245)
      "20:45"

  """
  @spec minutes_to_time(integer) :: binary
  def minutes_to_time(minutes) do
    hours = rem(div(minutes, 60), 24)
    minutes = rem(minutes, 60)

    Time.new!(hours, minutes, 0)
    |> Time.to_string()
    |> String.slice(0..4)
  end

  @doc """
  Convert a NaiveDateTime struct to a sliced Time string.

  ## Examples

      iex> naive_to_time(~N[2000-01-01 23:00:07])
      "23:00"

  """
  @spec naive_to_time(%{
          :calendar => any,
          :day => any,
          :hour => any,
          :microsecond => any,
          :minute => any,
          :month => any,
          :second => any,
          :year => any,
          optional(any) => any
        }) :: binary
  def naive_to_time(naive) do
    NaiveDateTime.to_time(naive)
    |> Time.to_string()
    |> String.slice(0..4)
  end

  @doc """
  Calculates minutes sum from a period time string.

  ## Examples

      iex> pt_to_minutes("PT8H03M")
      483

  """
  @spec pt_to_minutes(binary) :: integer
  def pt_to_minutes(period_time) do
    Regex.named_captures(~r/((?<H>\d*)H)(?:(?<M>\d*)M)?/, period_time)
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Enum.reduce(0, fn
      {"H", value}, acc -> String.to_integer(value) * 60 + acc
      {"M", value}, acc -> String.to_integer(value) + acc
    end)
  end
end
