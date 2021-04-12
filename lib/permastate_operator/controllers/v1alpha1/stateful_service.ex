defmodule PermastateOperator.Controller.V1alpha1.StatefulService do
  @moduledoc """
  PermastateOperator: StatefulService CRD.

  ## Kubernetes CRD Spec
  Cloudstate StatefulService CRD

  ### Examples
  ```
  apiVersion: cloudstate.io/v1alpha1
  kind: StatefulService
  metadata:
    name: shopping-cart
  spec:
    containers:
    - image: my-docker-hub-username/shopping-cart:latest
  ```
  """

  require Logger
  use Bonny.Controller

  @version "v1alpha1"

  @rule {"apps", ["deployments"], ["*"]}
  @rule {"", ["services", "pods", "configmap"], ["*"]}

  # It would be possible to call @group "permastate.eigr.io"
  # However, to maintain compatibility with the original protocol, we will call it cloudstate.io
  @group "cloudstate.io"

  @scope :namespaced
  @names %{
    plural: "statefulservices",
    singular: "statefulservice",
    kind: "StatefulService",
    shortNames: ["st", "stss"]
  }

  # @additional_printer_columns [
  #  %{
  #    name: "test",
  #    type: "string",
  #    description: "test",
  #    JSONPath: ".spec.test"
  #  }
  # ]

  @doc """
  Called periodically for each existing CustomResource to allow for reconciliation.
  """
  @spec reconcile(map()) :: :ok | :error
  @impl Bonny.Controller
  def reconcile(payload) do
    track_event(:reconcile, payload)
    :ok
  end

  @doc """
  Creates a kubernetes `statefulset`, `service` and `configmap` that runs a "Cloudstate" app.
  """
  @spec add(map()) :: :ok | :error
  @impl Bonny.Controller
  def add(payload) do
    track_event(:add, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.create(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.create(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Updates `statefulset`, `service` and `configmap` resources.
  """
  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(payload) do
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.patch(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.patch(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Deletes `statefulset`, `service` and `configmap` resources.
  """
  @spec delete(map()) :: :ok | :error
  @impl Bonny.Controller
  def delete(payload) do
    track_event(:delete, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.delete(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.delete(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse(%{
         "kind" => "StatefulService",
         "metadata" => %{"name" => name, "namespace" => ns},
         "spec" => %{"containers" => containers}
       }) do
    statefulset = gen_statefulset(ns, name, containers)
    service = gen_service(ns, name)
    configmap = gen_configmap(ns)

    %{
      configmap: configmap,
      statefulset: statefulset,
      service: service
    }
  end

  defp gen_configmap(ns) do
    %{
      "apiVersion" => "v1",
      "kind" => "ConfigMap",
      "metadata" => %{
        "namespace" => ns,
        "name" => "proxy-cm"
      },
      "data" => %{
        "NODE_COOKIE" => "6eycE1E/S341t4Bcto262ffyFWklCWHQIKloJDJYR7Y=",
        "PROXY_APP_NAME" => "proxy",
        "PROXY_CLUSTER_POLLING" => "3000",
        "PROXY_CLUSTER_STRATEGY" => "kubernetes-dns",
        "PROXY_HEADLESS_SERVICE" => "proxy-headless-svc",
        "PROXY_HEARTBEAT_INTERVAL" => "240000",
        "PROXY_HTTP_PORT" => "9001",
        "PROXY_PORT" => "9000",
        "PROXY_ROOT_TEMPLATE_PATH" => "/home/app",
        "PROXY_UDS_ADDRESS" => "/var/run/cloudstate.sock",
        "PROXY_UDS_MODE" => "false",
        "USER_FUNCTION_HOST" => "127.0.0.1",
        "USER_FUNCTION_PORT" => "8080"
      }
    }
  end

  defp gen_service(ns, name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => "proxy-headless-svc",
        "namespace" => ns,
        "labels" => %{"svc-cluster-name" => "svc-proxy-#{name}-cluster"}
      },
      "spec" => %{
        "selector" => %{"cluster-name" => "proxy-#{name}-cluster"},
        "ports" => [
          %{"port" => 4369, "name" => "epmd"},
          %{"port" => 9000, "name" => "proxy"},
          %{"port" => 9001, "name" => "http"}
        ]
      }
    }
  end

  defp gen_statefulset(ns, name, containers) do
    container = List.first(containers)
    image = map["image"]

    %{
      "apiVersion" => "apps/v1",
      "kind" => "StatefulSet",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name}
      },
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{"app" => name, "cluster-name" => "proxy-#{name}-cluster"}
        },
        "serviceName" => "proxy-headless-svc",
        "replicas" => 1,
        "template" => %{
          "metadata" => %{
            "annotations" => %{
              "prometheus.io/port" => "9001",
              "prometheus.io/scrape" => "true"
            },
            "labels" => %{"app" => name, "cluster-name" => "proxy-#{name}-cluster"}
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "massa-proxy",
                "image" => "docker.io/eigr/massa-proxy:0.1.0",
                "env" => [
                  %{
                    "name" => "NODE_COOKIE",
                    "value" => "massa_proxy_6eycE1E/S341t4Bcto262ffyFWklCWHQIKloJDJYR7Y="
                  },
                  %{
                    "PROXY_POD_IP" => %{
                      "valueFrom" => %{"fieldRef" => %{"fieldPath" => "status.podIP"}}
                    }
                  }
                ],
                "ports" => [
                  %{"containerPort" => 9000},
                  %{"containerPort" => 9001},
                  %{"containerPort" => 4369}
                ],
                "livenessProbe" => %{
                  "failureThreshold" => 10,
                  "httpGet" => %{
                    "path" => "/health",
                    "port" => 9001,
                    "scheme" => "HTTP"
                  },
                  "initialDelaySeconds" => 300,
                  "periodSeconds" => 3600,
                  "successThreshold" => 1,
                  "timeoutSeconds" => 1200
                },
                "resources" => %{
                  "limits" => %{
                    "memory" => "1024Mi"
                  },
                  "requests" => %{
                    "memory" => "70Mi"
                  }
                },
                "envFrom" => [
                  %{
                    "configMapRef" => %{"name" => "proxy-cm"}
                  }
                ]
              },
              %{
                "name" => "user-function",
                "image" => image,
                "ports" => [
                  %{"containerPort" => 8080}
                ]
              }
            ]
          }
        }
      }
    }
  end

  defp run(%K8s.Operation{} = op),
    do: K8s.Client.run(op, Bonny.Config.cluster_name())

  defp track_event(type, resource),
    do: Logger.info("#{type}: #{inspect(resource)}")
end