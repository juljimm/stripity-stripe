defmodule Stripe.StripeTest do
  use ExUnit.Case
  import Mock

  setup_all do
    HTTPoison.start
  end

  test "process_url for v1" do
    assert Stripe.process_url("payment") == "https://api.stripe.com/v1/payment"
  end

  test "make_request_with_key fails when no key is supplied on environment config" do
    with_mock System, [get_env: fn(_opts) -> nil end] do
      assert_raise Stripe.MissingSecretKeyError, fn ->
        Stripe.config_or_env_key
      end
    end
  end

  test "make_request_with_key fails when no key is supplied on stripe request" do
    res = Stripe.make_request_with_key(
      :get,"plans?limit=0&include[]=total_count","")
            |> Stripe.Util.handle_stripe_response
    case res do
        {:error, err} -> assert String.contains? err["error"]["message"], "YOUR_SECRET_KEY"
        true -> assert false
    end
  end

  test "make_request_with_key works when valid key is supplied" do
    res = Stripe.make_request_with_key(
      :get,"plans?limit=0&include[]=total_count", Stripe.config_or_env_key)
        |> Stripe.Util.handle_stripe_response
    case res do
      {:ok, _} -> assert(true == true)
      {:error, err} -> inspect(err) |> flunk
    end
  end

end
