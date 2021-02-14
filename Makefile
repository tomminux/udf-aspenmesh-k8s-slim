# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

AM_NAMESPACE=istio-system
AM_VALUES=./udf/udf-values-cluster.yaml
CHART_DIR=./aspenmesh-1.6.14-am2/manifests/charts

namespace-preparation: 
    kubectl apply -f ~/k8s-manifests/istio-system/0.namespace-preparation/0.namespace.yaml
    kubectl apply -f ~/k8s-manifests/istio-system/0.namespace-preparation/1.storageClass.yaml
    kubectl apply -f ~/k8s-manifests/istio-system/0.namespace-preparation/2.pvc.yaml
	kubectl patch storageclass infra-server-nfs-server-istio -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

install-am: ## Install aspen mesh in k8s cluster
	helm install istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm install istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
	helm install istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
	helm install istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES}

upgrade-am: ## Upgrade aspen mesh in k8s cluster
	helm upgrade istio-base ${CHART_DIR}/base --namespace ${AM_NAMESPACE}
	helm upgrade istiod ${CHART_DIR}/istio-control/istio-discovery --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
	# helm upgrade istio-ingress ${CHART_DIR}/gateways/istio-ingress --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
	# helm upgrade istio-egress ${CHART_DIR}/gateways/istio-egress --namespace ${AM_NAMESPACE} --values ${AM_VALUES}
	helm upgrade istio-telemetry ${CHART_DIR}/istio-telemetry/grafana --namespace ${AM_NAMESPACE} --values ${AM_VALUES}

uninstall-am: ## Uninstall aspen mesh in k8s cluster
	helm uninstall istio-telemetry --namespace ${AM_NAMESPACE} || true
	# helm uninstall istio-egress --namespace ${AM_NAMESPACE} || true
	# helm uninstall istio-ingress --namespace ${AM_NAMESPACE} || true
	helm uninstall istiod --namespace ${AM_NAMESPACE} || true
	helm uninstall istio-base --namespace ${AM_NAMESPACE} || true
	kubectl delete ns ${AM_NAMESPACE} || true


#post-install: ## Extra installations after standard installation
#	kubectl apply -f ./udf/post-install
