defmodule Eigr.FunctionsController.K8S.Ingress.Glbc do
  @behaviour Eigr.FunctionsController.K8S.Ingress.Controller

  def get_class(%{"className" => "gce"}), do: "gce"

  def get_path_type(_params) do
  end

  def get_annotations(params) do
    {:nothing, params}
  end

  def get_tls_secret(params) do
    host = params["host"]
    status = params["useTls"]

    if status do
      secretName = params["tls"]["secretName"]
      {:ok, %{"tls" => %{"secretName" => "#{secretName}", "hosts" => ["#{host}"]}}}
    else
      {:nothing, params}
    end
  end
end
