apply:
	kubectl apply -f namespace.yml && \
	kubectl apply -f services.yml

calico:
	calicoctl apply -f networkpolicy/calico/ && \
	calicoctl get -n private-networking networkpolicy

k8s-networking-policy:
	kubectl apply -f networkpolicy/

delete: delete-k8s-network-policy delete-calico
	kubectl delete -f .

delete-k8s-network-policy:
	-kubectl delete -f networkpolicy
	true

delete-calico:
	-calicoctl delete -f networkpolicy/calico/
	true

test:
	@echo "Test access from A to B"
	@-kubectl exec \
	  -n private-networking \
	  "$$(kubectl get pods -n private-networking -l service=service-a -o json | jq -r '.items[] | .metadata.name')" \
	  -- wget -T10 -O - service-b.private-networking

	@echo "Test access from B to A"
	@-kubectl exec \
	  -n private-networking \
	  "$$(kubectl get pods -n private-networking -l service=service-b -o json | jq -r '.items[] | .metadata.name')" \
	  -- wget -T10 -O - service-a.private-networking
